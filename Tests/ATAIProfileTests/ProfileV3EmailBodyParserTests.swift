import Foundation
import Testing
import UIKit
@testable import ATAIProfile

@Suite("Email body")
struct ProfileV3EmailBodyParserTests {
    @Test func aGmailReplyFoldsItsQuotedHistoryWithoutArrows() throws {
        let html = """
        <div dir="ltr"><div>Hi Ayl,</div><div><br></div><div>Please share:</div><ul><li>Passport copy</li>\
        <li>Intended travel dates</li></ul><div>Best regards,<br>Team visa</div></div><br>\
        <div class="gmail_quote gmail_quote_container"><div dir="ltr" class="gmail_attr">On Thu, Nov 12, 2026 at 2:04 PM \
        Sam &lt;<a href="mailto:sam@example.com">sam@example.com</a>&gt; wrote:<br></div>\
        <blockquote class="gmail_quote" style="margin:0px 0px 0px 0.8ex;border-left:1px solid rgb(204,204,204)">\
        Hello,<br><br>I&#39;m Ayl, writing on behalf of Alex.<br></blockquote></div>
        """
        let body = try #require(ProfileV3EmailBodyParser.fromHTML(html))
        #expect(body.message.plain == "Hi Ayl,\n\nPlease share:\n\n• Passport copy\n• Intended travel dates\n\nBest regards,\nTeam visa")
        let quoted = try #require(body.quoted)
        #expect(quoted.plain == "On Thu, Nov 12, 2026 at 2:04 PM Sam <sam@example.com> wrote:\n\nHello,\n\nI'm Ayl, writing on behalf of Alex.")
        #expect(!quoted.plain.contains(">\n") && !quoted.plain.contains("\n>"))
        let mailLink = quoted.runs.contains { $0.link == URL(string: "mailto:sam@example.com") }
        #expect(mailLink)
    }

    @Test func aGmailForwardKeepsTheForwardedMessage() throws {
        let html = """
        <div dir="ltr">FYI<br><br><div class="gmail_quote"><div dir="ltr" class="gmail_attr">\
        ---------- Forwarded message ---------<br>From: <strong class="gmail_sendername">IndiGo</strong> \
        &lt;<a href="mailto:noreply@example.com">noreply@example.com</a>&gt;<br>Subject: Booking confirmed<br></div>\
        <br><br><div>Your PNR is <b>ABC123</b>.</div></div></div>
        """
        let body = try #require(ProfileV3EmailBodyParser.fromHTML(html))
        #expect(body.quoted == nil)
        #expect(body.message.plain.hasPrefix("FYI\n\n---------- Forwarded message ---------\nFrom: IndiGo <noreply@example.com>"))
        #expect(body.message.plain.hasSuffix("Subject: Booking confirmed\n\nYour PNR is ABC123."))
        let boldPNR = body.message.runs.contains { $0.text == "ABC123" && $0.isBold }
        #expect(boldPNR)
    }

    @Test func anAppleMailReplyFoldsFromTheFirstQuote() throws {
        let html = """
        <html><head><meta charset="utf-8"><style>p { margin: 0 } .x::before { content: "<b>" }</style>\
        <title>Re: Visa</title></head><body dir="auto">Sounds good.<div><br><blockquote type="cite">\
        On 12 Nov 2026, at 14:04, Sam &lt;sam@example.com&gt; wrote:<br><br></blockquote></div>\
        <blockquote type="cite"><div dir="ltr">Hello,<br>Can you book the visa?</div></blockquote></body></html>
        """
        let body = try #require(ProfileV3EmailBodyParser.fromHTML(html))
        #expect(body.message.plain == "Sounds good.")
        #expect(body.quoted?.plain == "On 12 Nov 2026, at 14:04, Sam <sam@example.com> wrote:\n\nHello,\nCan you book the visa?")
    }

    @Test func anAttributionOutsideTheQuoteMovesWithIt() throws {
        let body = try #require(ProfileV3EmailBodyParser.fromHTML(
            "<p>Sounds good.</p><p>On Thu, Sam wrote:</p><blockquote><p>Hello</p></blockquote>"
        ))
        #expect(body.message.plain == "Sounds good.")
        #expect(body.quoted?.plain == "On Thu, Sam wrote:\n\nHello")
    }

    @Test func aQuoteInsideTheReplyStaysInPlace() throws {
        let body = try #require(ProfileV3EmailBodyParser.fromHTML("<blockquote>Can you travel on Friday?</blockquote><p>Yes, Friday works.</p>"))
        #expect(body.quoted == nil)
        #expect(body.message.plain == "Can you travel on Friday?\n\nYes, Friday works.")
        #expect(body.message.runs.first?.isQuoted == true)
        #expect(body.message.runs.last?.isQuoted == false)
    }

    @Test func anEmailThatIsOnlyAQuoteShowsIt() throws {
        let body = try #require(ProfileV3EmailBodyParser.fromHTML("<blockquote>Forwarded note</blockquote>"))
        #expect(body.message.plain == "Forwarded note")
        #expect(body.quoted == nil)
    }

    @Test func hiddenTextScriptsAndUnsafeLinksAreDropped() throws {
        let html = """
        <div style="display: none; max-height:0">Preheader text&zwnj;&nbsp;&zwnj;</div>\
        <table><tr><td>Hello&nbsp;there &amp; welcome</td><td>&#8377;1,200</td></tr><tr><td>Line two</td></tr></table>\
        <p>Visit <a href="https://example.com/booking?id=1&amp;x=2">your booking</a> or <a href="javascript:alert(1)">this</a>.</p>\
        <script>var x = "<p>no</p>";</script><!-- <p>comment</p> -->
        """
        let body = try #require(ProfileV3EmailBodyParser.fromHTML(html))
        #expect(body.message.plain == "Hello there & welcome ₹1,200\nLine two\n\nVisit your booking or this.")
        let links = body.message.runs.filter { $0.link != nil }
        #expect(links.map(\.text) == ["your booking"])
        #expect(links.first?.link == URL(string: "https://example.com/booking?id=1&x=2"))
    }

    @Test func headingsListsAndEmphasisKeepTheirShape() throws {
        let body = try #require(ProfileV3EmailBodyParser.fromHTML(
            "<h2>Your trip</h2><ol start=\"3\"><li>Pack<li><b>Fly</b> <i>early</i></ol><p>Done</p>"
        ))
        #expect(body.message.plain == "Your trip\n\n3. Pack\n4. Fly early\n\nDone")
        let bold = body.message.runs.filter(\.isBold).map(\.text)
        let italic = body.message.runs.filter(\.isItalic).map(\.text)
        #expect(bold == ["Your trip", "Fly"])
        #expect(italic == ["early"])
    }

    @Test func aPlainTextReplyFoldsItsArrowedLines() throws {
        let text = "Thanks, we'll review.\r\n\r\nOn Thu, Nov 12, 2026, 2:04 PM Sam\r\n<sam@example.com> wrote:\r\n\r\n"
            + "> Hello,\r\n>\r\n> I'm Ayl.\r\n> > Older line\r\n"
        let body = try #require(ProfileV3EmailBodyParser.fromText(text))
        #expect(body.message.plain == "Thanks, we'll review.")
        #expect(body.quoted?.plain == "On Thu, Nov 12, 2026, 2:04 PM Sam\n<sam@example.com> wrote:\n\nHello,\n\nI'm Ayl.\nOlder line")
    }

    @Test func plainTextWithoutAQuoteIsKeptWhole() throws {
        let body = try #require(ProfileV3EmailBodyParser.fromText("  Hello\n\n\n\nthere > here\n"))
        #expect(body.message.plain == "Hello\n\nthere > here")
        #expect(body.quoted == nil)
        #expect(ProfileV3EmailBodyParser.fromText(" \n ") == nil)
    }

    @Test func htmlWinsOverTextAndEmptyHTMLFallsBack() throws {
        #expect(ProfileV3EmailBodyParser.body(html: "<p>From html</p>", text: "From text")?.message.plain == "From html")
        #expect(ProfileV3EmailBodyParser.body(html: "<div style=\"display:none\">x</div>", text: "From text")?.message.plain == "From text")
        #expect(ProfileV3EmailBodyParser.body(html: nil, text: nil) == nil)
    }

    @Test func theDetailNoteLeavesOutTheQuotedHistory() throws {
        let row = ProfileV3GloveBoxEmail(id: "a", sender: "Team visa", summary: "Re: Visa")
        let dto = try JSONDecoder().decode(
            ProfileV3GloveBoxMessageDTO.self,
            from: Data(#"""
            {"id":"a","html":"<div>Noted.</div><div class=\"gmail_quote\"><div class=\"gmail_attr\">On Thu, Sam wrote:</div><blockquote class=\"gmail_quote\">Hello</blockquote></div>",
             "text":"Noted.\n\nOn Thu, Sam wrote:\n\n> Hello"}
            """#.utf8)
        )
        let email = ProfileV3GloveBoxMapper.detail(dto, listItem: row)
        #expect(email.note == "Noted.")
        #expect(email.body?.quoted?.plain == "On Thu, Sam wrote:\n\nHello")
    }

    @Test @MainActor func theQuotedPartShowsOnlyWhenAskedAndLinksStayTappable() throws {
        let body = try #require(ProfileV3EmailBodyParser.fromHTML(
            "<p>See <a href=\"https://example.com\">this</a></p><div class=\"gmail_quote\"><blockquote class=\"gmail_quote\">Old</blockquote></div>"
        ))
        let folded = ProfileV3EmailBodyText.attributed(body, showsQuoted: false, color: .black)
        let open = ProfileV3EmailBodyText.attributed(body, showsQuoted: true, color: .black)
        #expect(folded.string == "See this")
        #expect(open.string == "See this\n\nOld")
        let linkRange = (folded.string as NSString).range(of: "this")
        #expect(folded.attribute(.link, at: linkRange.location, effectiveRange: nil) as? URL == URL(string: "https://example.com"))
        let oldColor = open.attribute(.foregroundColor, at: (open.string as NSString).range(of: "Old").location, effectiveRange: nil) as? UIColor
        #expect(oldColor?.cgColor.alpha == CGFloat(ProfileV3Theme.GloveBox.Palette.quotedOpacity))

        let view = ProfileV3FlowingTextView()
        view.configure(text: "See this", attributed: folded, style: .H7InterMedium16, color: .black, exclusion: .zero)
        #expect(view.isSelectable)
        view.configure(text: "Plain", style: .H7InterMedium16, color: .black, exclusion: .zero)
        #expect(!view.isSelectable)
    }
}
