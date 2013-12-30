# encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "when querying a remote service" do
	
	describe "when the service returns no data" do

		it "should return an empty json" do
		  VCR.use_cassette('empty') do
		    fc2json = FC2Json.new "http://services2.arcgis.com/hMIIIBIOpi8Cdgjw/arcgis/rest/services/ubs/FeatureServer/0", "FID", 1000, "1 > 2"
		    fc2json.get.should be_empty
		  end
		end

	end

	describe "when the service returns data" do

		it "should return a set compatible with where clause" do
			VCR.use_cassette("1000_batch_size") do
				fc2json = FC2Json.new "http://services2.arcgis.com/hMIIIBIOpi8Cdgjw/arcgis/rest/services/ubs/FeatureServer/0", "FID", 1000, "FID >= 1 and FID <=6"
				fc2json.get["features"].count.should == 6
			end
		end

		it "should return data when query batch is equal to dataset size" do
			VCR.use_cassette("6_batch_size") do
				fc2json = FC2Json.new "http://services2.arcgis.com/hMIIIBIOpi8Cdgjw/arcgis/rest/services/ubs/FeatureServer/0", "FID", 6, "FID >= 1 and FID <=6"
				fc2json.get["features"].count.should == 6
			end
		end

		it "should return data when query batch is less than dataset size" do
			VCR.use_cassette("3_batch_size") do
				fc2json = FC2Json.new "http://services2.arcgis.com/hMIIIBIOpi8Cdgjw/arcgis/rest/services/ubs/FeatureServer/0", "FID", 3, "FID >= 1 and FID <=6"
				fc2json.get["features"].count.should == 6
			end

			VCR.use_cassette("4_batch_size") do
				fc2json = FC2Json.new "http://services2.arcgis.com/hMIIIBIOpi8Cdgjw/arcgis/rest/services/ubs/FeatureServer/0", "FID", 4, "FID >= 1 and FID <=6"
				fc2json.get["features"].count.should == 6
			end
		end

		it "should raise error when batch size is greater than the size supported by the service" do
			VCR.use_cassette("3000_batch_size") do
				fc2json = FC2Json.new "http://services2.arcgis.com/hMIIIBIOpi8Cdgjw/arcgis/rest/services/ubs/FeatureServer/0", "FID", 3000, "FID >= 1 and FID <=3001"
				expect{fc2json.get}.to raise_error(ArgumentError, "The batch size of 3000 exceeds the capability provided by the service used on this query. Review the service's batch size limit and adjust your query parameters.")
			end
		end

	end

end


