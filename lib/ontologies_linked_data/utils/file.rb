require 'net/http'
require 'uri'
require 'zip'

module LinkedData
  module Utils
    module FileHelpers

      def self.zip?(file_path)
        file_path = file_path.to_s
        unless File.exist? file_path
          raise ArgumentError, "File path #{file_path} not found"
        end
        file_type = `file --mime -b #{Shellwords.escape(file_path)}`
        return file_type.split(";")[0] == "application/zip"
      end

      def self.files_from_zip(file_path)
        file_path = file_path.to_s
        unless File.exist? file_path
          raise ArgumentError, "File path #{file_path} not found"
        end
        files = []
        Zip::File.open(file_path) do |zipfile|
          zipfile.each do |file|
            if not file.directory?
              if not file.name.split("/")[-1].start_with? "." #a hidden file in __MACOSX or .DS_Store
                files << file.name
              end
            end
          end
        end
        return files
      end

      def self.unzip(file_path, dst_folder)
        file_path = file_path.to_s
        dst_folder = dst_folder.to_s
        unless File.exist? file_path
          raise ArgumentError, "File path #{file_path} not found"
        end
        unless Dir.exist? dst_folder
          raise ArgumentError, "Folder path #{dst_folder} not found"
        end
        extracted_files = []
        Zip::File.open(file_path) do |zipfile|
          zipfile.each do |file|
            if file.name.split("/").length > 1
              sub_folder = File.join(dst_folder,
                                    file.name.split("/")[0..-2].join("/"))
              unless Dir.exist?(sub_folder)
                FileUtils.mkdir_p sub_folder
              end
            end
            extracted_files << file.extract(File.join(dst_folder,file.name))
          end
        end
        return extracted_files
      end

      def self.repeated_names_in_file_list(file_list)
        return file_list.group_by {|x| x.split("/")[-1]}.select { |k,v| v.length > 1}
      end

      def self.exists_and_file(path)
        path = path.to_s
        return (File.exist?(path) and (not File.directory?(path)))
      end

      def self.download_file(uri, limit = 10)
        raise ArgumentError, 'HTTP redirect too deep' if limit == 0

        uri = URI(uri) unless uri.kind_of?(URI)

        if uri.kind_of?(URI::FTP)
          file, filename = download_file_ftp(uri)
        else
          file = Tempfile.new('ont-rest-file')
          file_size = 0
          filename = nil
          http_session = Net::HTTP.new(uri.host, uri.port)
          http_session.verify_mode = OpenSSL::SSL::VERIFY_NONE
          http_session.use_ssl = (uri.scheme == 'https')
          http_session.start do |http|
            http.read_timeout = 1800
            http.request_get(uri.request_uri, {"Accept-Encoding" => "gzip"}) do |res|
              if res.kind_of?(Net::HTTPRedirection)
                new_loc = res['location']
                if new_loc.match(/^(http:\/\/|https:\/\/)/)
                  uri = new_loc
                else
                  uri.path = new_loc
                end
                return download_file(uri, limit - 1)
              end

              raise Net::HTTPBadResponse.new("#{uri.request_uri}: #{res.code}") if res.code.to_i >= 400

              file_size = res.read_header["content-length"].to_i
              begin
                filename = res.read_header["content-disposition"].match(/filename=\"(.*)\"/)[1] if filename.nil?
              rescue
                filename = LinkedData::Utils::Triples.last_iri_fragment(uri.request_uri) if filename.nil?
              end

              file.write(res.body)

              if res.header['Content-Encoding'].eql?('gzip')
                uncompressed_file = Tempfile.new("uncompressed-ont-rest-file")
                file.rewind
                sio = StringIO.new(file.read)
                gz = Zlib::GzipReader.new(sio)
                uncompressed_file.write(gz.read())
                file.close
                file = uncompressed_file
                gz.close()
              end
            end
          end
          file.close
        end

        return file, filename
      end

      def self.download_file_ftp(url)
        url = URI.parse(url) unless url.kind_of?(URI)
        ftp = Net::FTP.new(url.host, url.user, url.password)
        ftp.passive = true
        ftp.login
        filename = LinkedData::Utils::Triples.last_iri_fragment(url.path)
        tmp = Tempfile.new(filename)
        ftp.getbinaryfile(url.path) do |chunk|
          tmp << chunk
        end
        tmp.close
        return tmp, filename
      end

    end
  end
end
