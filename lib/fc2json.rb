# encoding: utf-8
require 'open-uri'
require 'cgi'
require 'json'
require 'nokogiri'

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

class FC2Json
	attr_accessor :service_url, :object_identifier_field_name, :records_per_request, :where_clause

	def initialize (service_url, object_identifier_field_name = nil, records_per_request = nil, where_clause = nil)
		@service_url = service_url
		@object_identifier_field_name = object_identifier_field_name || "FID"
		@records_per_request = (records_per_request || 2000).to_i
		@where_clause = where_clause || "1 = 1"
	end

	def get
		ids = get_ids
		json = {}
		request_index = 0
		continue = true

		while continue do
			if ids[request_index * @records_per_request + (@records_per_request - 1)].nil?
				continue = false
				where = "#{@object_identifier_field_name} >= #{ids[request_index * @records_per_request]} AND #{@object_identifier_field_name} <= #{ids.last}"
			else
				where = "#{@object_identifier_field_name} >= #{ids[request_index * @records_per_request]} AND #{@object_identifier_field_name} <= #{ids[request_index * @records_per_request + (@records_per_request - 1)]}"
			end
			request_url = "#{@service_url}/query?where=#{CGI.escape(where)}&f=pjson&outFields=*"

			request_result = JSON.parse(Nokogiri::HTML(open(request_url)))
			if request_result["exceededTransferLimit"]
				raise ArgumentError, "The batch size of #{@records_per_request} exceeds the capability provided by the service used on this query. Review the service's batch size limit and adjust your query parameters."
			end

			if json.empty?
				json = request_result
			else
				json["features"].concat request_result["features"]
			end

			request_index += 1

			continue = false if continue && json["features"].count == ids.count
		end

		# Esri treats where clauses that returns no data as invalid. We return an empty hash instead.
		if json["error"]
			return {} if json["error"]["details"] == ["'where' parameter is invalid"]
		end

		json
	end

	private 

	def get_ids
		request_url = "#{self.service_url}/query?where=#{CGI.escape(self.where_clause)}&f=pjson&returnIdsOnly=true"
		(JSON.parse Nokogiri::HTML(open(request_url)))["objectIds"]
	end


end