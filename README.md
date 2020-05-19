# ActionSet

[![Build Status](https://travis-ci.com/fractaledmind/actionset.svg?branch=master)](https://travis-ci.com/fractaledmind/actionset)
[![codecov](https://codecov.io/gh/fractaledmind/actionset/branch/master/graph/badge.svg)](https://codecov.io/gh/fractaledmind/actionset)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'actionset', require: 'action_set'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install actionset

## Usage

In order to make the **`ActionSet`** helper methods available to your application, you need to `include` the module into your `ApplicationController`.

```ruby
class ApplicationController < ActionController::Base
    include ActionSet
end
```

Or, if you only want or need **`ActionSet`** in certain controllers, you can `include` the module directly into those controllers.

The simplest setup is to use the `process_set` helper method in your `index` action. Typically, `index` actions look something like the following:

```ruby
def index
  @things = Thing.all
end
```

In order to wire up the filtering, sorting, and paginating behaviors, we simply need to update our `index` action to:

```ruby
def index
  @things = process_set(Thing.all)
end
```

Now, `@things` will be properly filtered, sorted, and paginated according to the request parameters.

> **Note:** `process_set` applies pagination and will paginate your collection regardless of the request parameters. Unless there are request parameters overriding the defaults, your collection will be paginated to 25 items per page showing the first 25 items (page 1). If you want to only filter and sort _without_ paginating, simply use the `filter_set` and `sort_set` helper methods directly, e.g. `sort_set(filter_set(Thing.all))`

> **Note:** If you use some authorization library, like [`Pundit`](https://github.com/varvet/pundit), which applies authorization scoping to your `index` action, you can compose that behavior with **`ActionSet`** easily:
> ```ruby
> def index
>   @things = process_set(policy_scope(Thing.all))
> end
> ```

In addition to filtering, sorting, and paginating, **`ActionSet`** provides exporting functionality via the `export_set` helper method. One common use case is to have an `index` action that renders a filtered, sorted, and paginated collection, but allows for a CSV export as well. In such cases, you typically want the HTML collection to be paginated, but the CSV not to be. This behavior is also relatively simple to achieve:

```ruby
def index
  things = sort_set(filter_set(Thing.all))

  respond_to do |f|
    f.html  { @things = paginate_set(things) }
    f.csv   { export_set(things) }
  end
end
```

With our controller properly wired up, we now simply need to have our views submitting request parameters in the shape that **`ActionSet`** expects. **`ActionSet`** provides view helpers to simplify such work.

Sorting is perhaps the simplest to setup. To create an (ARIA accessible) anchor link to sort by some particular attribute, use the `sort_link_for` view helper. You pass the attribute name (or dot-separated path), and then can add the text for the link (defaults to title-casing your attribute) and/or any HTML attributes you'd like added to the anchor link. A notable feature of the `sort_link_for` helper is that it intelligently infers the sort direction from whatever the current request state is. That is, if no sorting has been applied for that attribute, the link will apply sorting to that attribute in the _ascending_ direction. If sorting is currently being applied for that attribute in the _ascending_ direction, the link will apply sorting to that attribute in the _descending_ direction, and vice versa.

Filtering is somewhat more involved. **`ActionSet`** expects filters to be placed under the `filter` request parameter, aside from that one expectation, we leave all other view layer implementation details up to you. You can build your filtering interface however best fits your application. However, if you need a simple default, we suggest the following pattern: a simple form on your `index` action view that simply reloads that action with whatever filter params the user has submitted. In Rails, building such a form is relatively simple:

```erb
<%= form_for(form_for_object_from_param(:filter),
             method: :get,
             url: things_path) do |form| %>
  <div class="form-group">
    <%= form.label(:attribute, class: 'control-label') %>
    <%= form.text_field(:attribute, class: 'form-control') %>
  </div>

  <div class="text-right">
    <%= form.submit 'Save', class: 'btn btn-primary' %>
  </div>
<% end %>
```

We tell the `form_for` helper to make a `GET` request back to our `index` action (`things_path` in this example). The only odd bit is what we pass as the object to `form_for`; you will note we pass `form_for_object_from_param(:filter)`. This `form_for_object_from_param` view helper is provided by **`ActionSet`** and does precisely what it says—it provides an object (an `OpenStruct` object to be precise) that encodes whatever request parameters are nested under the param name given, where that object will work properly with the `form_for` helper. This view helper allows us to build forms we the user's filter inputs will be retained across searches.

For pagination, like filtering, we don't enforce any view-layer specifics. You simply need to pass request parameters under the `paginate` param, specifically the `page` and `size` params. However, **`ActionSet`** does provide a simple default pagination UI component via the `pagination_links_for` view helper. You simply pass your processed set to this view helper, and it will render HTML in this structure:

![alt text](https://raw.githubusercontent.com/fractaledmind/actionset/master/pagination.png)

```html
<nav class="pagination" aria-label="Page navigation">
    <a class="page-link page-first" href="/foos?paginate%5Bpage%5D=1">« First</a>
    <a rel="prev" class="page-link page-prev" href="/foos?paginate%5Bpage%5D=1">‹ Prev</a>
    <span class="page-current">Page&nbsp;<strong>2</strong>&nbsp;of&nbsp;<strong>3</strong></span>
    <a rel="next" class="page-link page-next" href="/foos?paginate%5Bpage%5D=3">Next ›</a>
    <a class="page-link page-last" href="/foos?paginate%5Bpage%5D=3">Last »</a>
</nav>
```

## Configuration

### ActiveSet.configuration.on_asc_sort_nils_come

Example usage in an initializer:

```
  ActiveSet.configure do |c|
    c.on_asc_sort_nils_come = :first
  end
```

When `ActiveSet.configuration.on_asc_sort_nils_come == :last` (this is the default), null values will be sorted as if larger than any non-null value.

```
ASC => [-2, -1, 1, 2, nil]
DESC => [nil, 2, 1, -1, -2]
```

Otherwise sort nulls as if smaller than any non-null value.

```
ASC => [nil, -2, -1, 1, 2]
DESC => [2, 1, -1, -2, nil]
```

## Edge-Cases

If you are using MySQL as your database engine, you may run into various possible edge-cases:

- ensure your `float` and `decimal` columns have an appropriate `precision` and `scale` set (it appears the default is (5,2))
  + if, for example, you create a `float` column without any `precision` or `scale` defined, and you set a value to `12345.67`, the database will return `12345.7`. Similarly, if you set the value to `123456.78`, you will get back `123457.0`
  + https://dev.mysql.com/doc/refman/8.0/en/problems-with-float.html
  + https://jibai31.wordpress.com/2017/05/04/how-to-choose-your-mysql-encoding-and-collation/
  + https://dev.mysql.com/doc/refman/8.0/en/charset-collate.html
  + https://api.rubyonrails.org/v3.1.1/classes/ActiveRecord/ConnectionAdapters/TableDefinition.html#method-i-column
-

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

There are tests in `spec`. We only accept PRs with tests. To run tests:

- Install Ruby 2.4.6
- Create a local test database `actionset_test` in both MySQL and PostgreSQL
- Copy `spec/support/database.sample.yml` to `spec/support/database.yml` and enter your local credentials for the test databases
- Install development dependencies using `bundle install`
- Run tests using `bundle exec rspec`

We recommend to test large changes against multiple versions of Ruby and multiple dependency sets. Supported combinations are configured in `.travis.yml`. We provide some rake tasks to help with this:

- Install development dependencies using `bundle matrix:install`
- Run tests using `bundle matrix:spec`

Note that we have configured Travis CI to automatically run tests in all supported Ruby versions and dependency sets after each push. We will only merge pull requests after a green Travis build.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/fractaledmind/actionset.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
