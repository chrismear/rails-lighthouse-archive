class TestClient < ActiveResource::Base
  self.element_name = "test"
  self.site = "http://localhost"
end

ActiveResource::HttpMock.respond_to do |mock|
   mock.get "test.xml",{},IO.read("tmp.xml"),200
end
TestClient.format = ActiveResource::Formats::XmlFormat
test2 = TestClient.find :one, :from => "test.xml"
