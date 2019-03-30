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

The `ActiveSet` class provides convenience methods for filtering, sorting, paginating, and transforming collections of data-objects, whether `ActiveRecord::Relation`s or Ruby `Array`s or custom classes that extend the `Enumerable` module.

When calling a convenience method on an instance of `ActiveSet`, you pass only 1 argument: a plain-old-Ruby-hash that encodes the instructions for that operation. Each convenience method works with hashes of differing signatures.

## Filtering

`ActiveSet` allows for you to filter your collection by:

- "direct" attributes (i.e. for an `ActiveRecord` model, a database attribute)
- "computed" attributes (i.e. Ruby getter-methods on your data-objects)
- "associated" attributes (i.e. either direct or computed attributes on objects associated with your data-objects)
- "called" attributes (i.e. Ruby methods with non-zero arity)

The syntax for the instructions hash is relatively simple:

```ruby
{
  attribute: 'value',
  association: {
    field: 'value'
  },
  'association.field' => 'value',
  'attribute(operator)' => 1.0,
  association: {
    'field(operator)': 'value'
  },
  'association.field(operator)' => 'value',
}
```

Every entry in the instructions hash is treated and processed as an independent operation, and all operations are _conjoined_ ("AND"-ed). At the moment, you cannot use disjointed ("OR"-ed) operations.

The logic of this method is to attempt to process every instruction with the ActiveRecordStrategy, marking all successful attempts. If we successfully processed every instruction, we simply returned the processed result. If there are any instructions that went unprocessed, we take only those instructions and process them against the set processed by the ActiveRecordStrategy.

This filtering operation does not preserve the order of the filters, enforces conjunction, and will discard any unprocessable instruction.

For ActiveRecord sets, the various [ARel predicate methods](https://www.rubydoc.info/github/rails/arel/Arel/Predications) are available as operators:

- `eq`
- `not_eq`
- `eq_any`
- `not_eq_any`
- `eq_all`
- `not_eq_all`
- `in`
- `not_in`
- `in_any`
- `not_in_any`
- `in_all`
- `not_in_all`
- `lt`
- `lteq`
- `lt_any`
- `lteq_any`
- `lt_all`
- `lteq_all`
- `gt`
- `gteq`
- `gt_any`
- `gteq_any`
- `gt_all`
- `gteq_all`
- `matches`
- `does_not_match`
- `matches_any`
- `does_not_match_any`
- `matches_all`
- `does_not_match_all`

## Sorting

`ActiveSet` allows for multi-dimensional, multi-directional sorting across the same kinds of attributes as filtering ("direct", "computed", "associated", and "called").

The syntax for the instructions hash is relatively simple:

```ruby
{
  attribute: :desc,
  association: {
    field: :asc
  }
}
```

The logic for this method is to check whether all of the instructions appear to be processable by the ActiveRecordStrategy, and if they are to attempt to sort using the ActiveRecordStrategy (with all of the instructions, as you can't split sorting instructions). We then double check that all of the instructions were indeed successfully processed by the ActiveRecordStrategy, and if they were, we return that result. Otherwise (if either some instructions don't appear to be processable by ActiveRecord or some instructions weren't processed by ActiveRecord), we sort with the EnumerableStrategy.

## Paginating

`ActiveSet` also allows for paginating both ActiveRecord or plain Ruby enumerable sets.

The syntax for the instructions hash remains relatively simple:

```ruby
{
  size: 25,
  page: 1
}
```

Unlike the filtering or sorting operations, you do not have to pass an instructions hash, as the operation will default to paginating with a `size` of 25 and starting on `page` 1.

Paginating as an operation works with "direct" instructions (that is, the instructions don't represent attribute paths or column structures; the instructions hash is a simple, flat hash), and the operation requires all instruction entries together (as opposed to filtering for example, where we can process each instruction entry separately).

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

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/fractaledmind/actionset.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
