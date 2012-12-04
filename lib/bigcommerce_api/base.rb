module BigcommerceAPI

  # Example Class Method
  # def reserved(*names)
  #   class_variable_set(:@@reserved, names.collect{|x| x.to_s})
  # end

  class Base
    extend BigcommerceAPI

    include HTTParty
    format :json
    headers 'Accept' => "application/json"
    headers 'Content-Type' => "application/json"

    def initialize(params={})
      self.class.basic_auth params[:username], params[:api_key]
      self.class.base_uri(params[:store_url] + '/api/v2/')
    end

    def get_orders(options={})
      self.class.get("/orders.json", :query => options)
    end

    def get_time
      self.class.get('/time.json')
    end

    # this grabs all of the FIRST LEVEL attributes
    # it ignores hashed and constructed nested attributes,
    # since Big Commerce won't let us set those anyway
    def attributes(strip_empty=false)
      hash = {}
      self.instance_variables.each {|var| hash[var.to_s.delete("@")] = self.instance_variable_get(var) if (var.to_s['_hash'].nil? or var.to_s['_resource'].nil?) }
      hash = BigcommerceAPI::Resource.date_adjust(hash)
      BigcommerceAPI::Resource.clean!(hash) if strip_empty
      return hash
    end

    class << self
      def clean!(hash)
        hash.each do |k, v| 
          if v.is_a? Hash
            clean!(v)
          else
            hash.delete(k) if v.nil? or v == ''
          end
        end
      end

      # Returns the date formatted as
      # RFC 2822 string
      def to_rfc2822(datetime)
        datetime.strftime("%a, %d %b %Y %H:%M:%S %z")
      end
      
      def date_adjust(params)
        [:date_created, :date_modified, :date_last_imported, :date_shipped, :min_date_created, :max_date_created, :min_date_modified, :max_date_modified, :min_date_last_imported, :max_date_last_imported].each do |date|
          [date, date.to_s].each do |d|
            if params[d] and !params[d].nil? and params[d] != ''
              if params[d].is_a?(String)
                params[d] = DateTime.parse(params[d])
              end
              # params[d] = CGI::escape(to_rfc2822(params[d]))
              params[d] = to_rfc2822(params[d])
            end
          end
        end
        return params
      end
    end
    
    # # Thanks to Brandon Keepers for this little nugget:
    # # http://opensoul.org/blog/archives/2010/02/16/active-resource-in-practice/
    # class << self
    #   # If headers are not defined in a given subclass, then obtain
    #   # headers from the superclass.
    #   def headers
    #     if defined?(@headers)
    #       @headers
    #     elsif superclass != Object && superclass.headers
    #       superclass.headers
    #     else
    #       @headers ||= {}
    #     end
    #   end
      
    #   def api_key=(api_key)
    #     headers['X-API-KEY'] = api_key
    #   end
      
    #   def api_version=(v)
    #     headers['X-API-VERSION'] = v
    #   end
      
    #   def local=(v)
    #     self.site = 'http://localhost:3000/api/' if v
    #   end
      
    #   def test=(v)
    #     self.site = 'http://testing.whiplashmerch.com/api/' if v
    #   end
    
    # end
    
    # Example Instance Method
    # def class_name
    #   self.class.name.split('::').last.downcase
    # end
        
  end

end