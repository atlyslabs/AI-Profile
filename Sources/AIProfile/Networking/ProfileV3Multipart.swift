import Foundation

enum ProfileV3Multipart {
    struct Field {
        let name: String
        let value: String
    }

    struct FileField {
        let name: String
        let fileName: String
        let mimeType: String
        let data: Data
    }

    static func generateBoundary() -> String {
        "Boundary-\(UUID().uuidString)"
    }

    static func contentType(boundary: String) -> String {
        "multipart/form-data; boundary=\(boundary)"
    }

    static func buildBody(boundary: String, fields: [Field], files: [FileField]) -> Data {
        var body = Data()

        for field in fields {
            body.append(Data("--\(boundary)\r\n".utf8))
            body.append(Data("Content-Disposition: form-data; name=\"\(field.name)\"\r\n\r\n".utf8))
            body.append(Data("\(field.value)\r\n".utf8))
        }

        for file in files {
            body.append(Data("--\(boundary)\r\n".utf8))
            body.append(Data("Content-Disposition: form-data; name=\"\(file.name)\"; filename=\"\(file.fileName)\"\r\n".utf8))
            body.append(Data("Content-Type: \(file.mimeType)\r\n\r\n".utf8))
            body.append(file.data)
            body.append(Data("\r\n".utf8))
        }

        body.append(Data("--\(boundary)--\r\n".utf8))
        return body
    }
}
