# Customers Cart

This is an example of my work with Rails...keepin' my beginner's mind wide open.

Create a customer, running an external call to run fraud protection profiling on them. Add items to their shopping cart. Purchase those items. 

It's a contrived example to capture my knowledge at a point in time...meaning I likely know more by now. :)

## Getting started

Developed using Ruby 2.3.0 and Rails 4.2.6. Ensure that you have Ruby or RVM manager installed.

To install RVM run
`curl -sSL https://get.rvm.io | bash -s stable`

Installing Ruby
`rvm install 2.3.0 && bundle install`

## Database
Database name should be `customers-cart`. Set it up with: `rake db:recreate && rake db:recreate RAILS_ENV=test`.

## Tests
Run tests:

* Run all `rspec`
* Run a suite `rspec ./spec/libs/test_spec.rb`
* Run a single test `rspec ./spec/libs/test_spec.rb:38`
* Run FAST `spring rspec ./spec/libs/test_spec.rb` by prepending `spring` to any of the above examples to enable fast Rails reloading.

## Using this API
Included in this project is a [PAW](https://luckymarmot.com/paw) client file useful for testing. Alternatively, use the CURL
commands PAW generated as below for customer `123` with authorization password `GOOD` base 64 encoded in the header as `R09PRA==`.

### Create a customer
#### Request
```
curl -X "POST" "http://localhost:3000/api/v1/customers" -H "Cookie: request_method=POST" -H "Authorization: Basic R09PRA==" -H "Content-Type: application/json" -d "{\"id\":\"123\",\"first_name\":\"Rick\",\"last_name\":\"Cotter\",\"date_of_birth\":\"1999-08-28\"}"
```
#### Response
```
HTTP/1.1 201 Created
Content-Type: application/json; charset=utf-8

{
    "id": "123",
    "name": "Rick Cotter",
    "status": "approved",
    "date_of_birth": "1999-08-28",
    "cart": {
        "cart_total": "$0.0", // Only unpurchased items contribute
        "items": [
            {
                "id": "bbe86ec0-a9e3-442d-9932-e182da4d241c",
                "name": "Free Gift Card",
                "amount": "$50.0",
                "status": "purchased"
            }
        ]
    }
}
```

### List all customers
#### Request
```
curl -X "GET" "http://localhost:3000/api/v1/customers" -H "Authorization: Basic R09PRA==" -H "Content-Type: application/json" -d "{}"
```
#### Response
````
HTTP/1.1 200 OK
Content-Type: application/json; charset=utf-8

[
    {
        "id": "123"
    }
]
````
### Get a customer
#### Request
```
curl -X "GET" "http://localhost:3000/api/v1/customers/123" -H "Authorization: Basic R09PRA==" -H "Content-Type: application/json" -d "{}"
```
#### Response
````
HTTP/1.1 200 OK
Content-Type: application/json; charset=utf-8

{
    "id": "123",
    "name": "Rick Cotter",
    "status": "approved",
    "date_of_birth": "1999-08-28",
    "cart": {
        "cart_total": "$0.0", // Only unpurchased items contribute
        "items": [
            {
                "id": "[ITEM ID]",
                "name": "Free Gift Card",
                "amount": "$50.0",
                "status": "purchased"
            }
        ]
    }
}
````

### Add an item to a customer's shopping cart
#### Request
```
curl -X "POST" "http://localhost:3000/api/v1/customers/123/items" -H "Cookie: request_method=POST" -H "Authorization: Basic R09PRA==" -H "Content-Type: application/json" -d "{\"name\":\"bread\",\"amount\":1.00}"
```
#### Response
````
HTTP/1.1 201 Created
Content-Type: application/json; charset=utf-8

{
    "id": "[ITEM ID]",
    "name": "bread",
    "amount": "$1.0",
    "status": "in_cart"
}
````

### Purchase an item that from a customer's shopping cart
Substitute in the item ID to purchase as per GET customer then
#### Request
```
curl -X "PATCH" "http://localhost:3000/api/v1/customers/123/items/[ITEM ID]" -H "Cookie: request_method=PATCH"-H "Authorization: Basic R09PRA=="-H "Content-Type: application/json"-d "{\"status\":\"purchased\"}"
```
#### Response
````
HTTP/1.1 200 OK
Content-Type: text/plain; charset=utf-8
````
## A Few of My Favorite Things

Ruby and Rails are full of these of course but here are my favourites:

### Normalize nil, single or array to an array:
####  nil to empty array
```
v = nil
a = *v              # a == []
```
#### array to array
```
v = *[1, 2, 3]
a = *v              # a == [1, 2, 3]
```
#### single value to array
```
v = *'single'
a = *v              # a == ['single']        
```
#### as a method param
```
def method_name(*p)
end
```
#### or in a one liner the [] is needed
```
[*'single'].each {|i| ... }     
```

### Strong Config
Make sure your config exists exactly as you expect and provide cleaner access
by loading it into a nested OpenStruct. Elegant! See strong_config.rb

### Safe navigation
Both have their use cases but the new `&.` is arguably better when possible.

#### try - Old school but still has its place
Invalid methods can be attempted
```
123.try(:length) # results in nil
```
#### & - New and strict
Invalid methods cannot be attempted
```
123&.length # results in NoMethodError: undefined method 'length' for 123:Fixnum
```

### "OR ASSIGN"
Classic. If you don't know this where have you been?
```
a = nil     # a == nil
a ||= 'b'   # a == 'b'
a ||= 'c'   # a == 'b' i.e. no change
```

### Good Gems

* [apartment](https://github.com/influitive/apartment) Need an app or API that has test mode?
Often we're writing an app or API that customers will integrate with in a testing mode. They don't want to incur some
expense while they're just figuring things out. We'll stub those out those integrations. But how do we stop pollution of the database? Also, 
we don't want to set up another environment and keep it perfectly synced to production. Awesome!
* [browser-timezone-rails](https://github.com/kbaum/browser-timezone-rails) sets Rails timezone to browser's configured timezone.
* [mailcatcher](https://mailcatcher.me/) for local SMTP email testing.
* [money-rails](https://github.com/RubyMoney/money-rails) for money money money.
* [attribute_normalizer](https://github.com/mdeering/attribute_normalizer) Sure, we should put some onus on the API consumer to sanitize input.
but sometimes that can be too much - a barrier to integration by less technical parties. Remember, your API needs good UX too!
To ensure we get the input we want we should sanitize. For example, 
downcase all emails and ensure they have no whitespace prepended/appended.
I like the attribute_normalizer gem by which attributes can be declaritively sanitized 
prior to validation like: `normalize_attribute :email, with[:strip, :blank, :downcase]`.
* [rack-attack](https://github.com/kickstarter/rack-attack) rack middleware for blocking & throttling.
* [record_with_operator](https://github.com/nay/record_with_operator) when compliance requires tracking who updated a record.

### Service Pattern
Clean up your controllers and make them WAY easier to test. You won't regret it. Do it even when the controller is small.
https://blog.engineyard.com/2014/keeping-your-rails-controllers-dry-with-services

### Write API acceptance tests without Capybara
Sure, a perfect isolated API test over HTTP sounds good until they are slow and cumbersome - fraught with peril. It was written for UI testing. http://www.elabs.se/blog/34-capybara-and-testing-apis

Instead get very close external HTTP requests using RSpec's `type: :request`. No starting a service instance 
and you can easily seed data since you're still inside your server. Use it until you're bitten. https://www.relishapp.com/rspec/rspec-rails/docs/request-specs/request-spec

### Make SOA services / microservices
Not really a problem Rails but instead a design concept. Split that monolithic app into pieces. Don't integrate at the database. 
Nevermind that working with two projects and their migrations on one database is not fun, unwinding that will be even worse.
Maybe it is even time to try something non-rails. :) Don't believe me? You don't have to.

## A Few Of My Least Favorite Things
### JSON cleansing - what you see is not what you get
An API request like:
```
{"a": 1, "b": [], "c": [1, nil, 2]}  
```
results in in Rails 4
```
{"a": 1, "c": [1, 2]}
```
but coming soon in Rails 5 it will be marginally better as:
```
{"a": 1, b: nil, "c": [1, 2]}
```
purportedly due to security concerns with SQL generation in ActiveRecord. WTF?

### ActiveRecord model validations don't always tell the whole story

#### Booleans are hard to validate
If an ActiveRecord model is being used to validate, a non-boolean will be cast to a boolean as false in 4.* but coming in 5.* it will be case to true. Crazy!
Regardless, the boolean value will never fail validation. 

Enums are a better choice since:

* They more clearly describe their state
* More than two options are available
* They can be validated easily

#### Dates are hard to validate
Similar to booleans, when a non-date is assigned to an ActiveRecord model it is cast to a date. Custom validation must be used in which this funky snippet is valuable.

```
# Use:
#    validate :validate_field
#
#    def validate_field
#      CustomValidator.validate(self, :field_name) # or
#      CustomValidator.validate(self, :field_name, {allow_nil: true})
#    end
#
class CustomValidator
  def self.validate(record, attribute, options=nil, error_message=nil)
    value = record.try(:attributes_before_type_cast).try(:[], attribute.to_s)
    unless value.nil? && (options || {})[:allow_nil]
      unless value.to_s =~ /^(19|20)\d\d-(0[1-9]|1[012])-(0[1-9]|[12][0-9]|3[01])$/
        record.errors[attribute] << (error_message || 'Default message here')
      end
    end
  end
end
```

#### You're going Postgres and you're not coming back (for a while)
Postgres is great. I'm continually impressed. But sometimes a thing is by nature a document. 
Often, if the manual process was using a document that is a hint.
That said, Postgres JSONB is starting to look pretty darn cool. It takes evaluation 
of use cases and team commitment but it can be worth. Half of Rails seems to be about
packing and unpacking data - often to and from what is a document.

#### Model callbacks are cool...until they're not
***Holy hidden behaviour Batman!***


