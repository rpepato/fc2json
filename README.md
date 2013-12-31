fc2json
==================

When querying a esri feature service to get all data published through it, it is needed to deal with the limitation on the number
of records returned by the server. fc2json abstracts the tasks needed to get all data from a esri feature service.

###Usage

Install the gem as usual:

```ruby
gem install fc2json
```

Create an instance of a FC2Json object, passing it the service url as a parameter. After creating the instance, just call the get method on it to get a json object with all the data exposed by the service. The following code presents a sample on downloading and saving the service data to a file:

```ruby
File.open("output.json", 'w') do |file|
	file.write FC2Json.new("http://services2.arcgis.com/hMIIIBIOpi8Cdgjw/arcgis/rest/services/ubs/FeatureServer/0").get
end
```

####Initialization parameters

The constructor of a FC2Json object is declared as follows:

```ruby
def initialize (service_url, object_identifier_field_name = nil, records_per_request = nil, where_clause = nil)
end
```

The construction parameters are:

* __service_url:__ Mandatory. The url for the feature service. 
* __object_identifier_field_name:__ Optional. The name of the field used as an object identifier on the feature service. If not provided, defaults to "FID"
* __records_per_request:__ Optional. The number of records returned on each request to the service. Be aware that if you specify a number greater than the max number of records configured on the service, an ArgumentError will be raised. If not provided, defaults to 2000.
* __where_clause:__ Optional. The where condition (SQL query) to filter the records on the feature service. If not provided, defaults to "1 = 1"

####Binary usage
If you prefer you can use the binary provided by the gem and redirect the output to a file:

```shell
fc2json "http://services2.arcgis.com/hMIIIBIOpi8Cdgjw/arcgis/rest/services/ubs/FeatureServer/0" "FID" 6 "FID >= 1 and FID <=6" > output.json 
```

###Contributing to fc2json
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

###Copyright

Copyright (c) 2013 rpepato. See LICENSE.txt for
further details.

