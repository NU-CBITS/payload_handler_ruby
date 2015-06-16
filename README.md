# Payload handler

This is a utility library designed to implement read and upsert functionality
for mixed resource payloads. It assumes an Active Record-like API.

## TODO

For efficiency, it should be possible to filter resources, such as by date
range.

## Resources

A resource class must accept a hash of properties as an agument for its
`initialize` method. It must also implement `save`, `serialize` and `errors`
methods.

## Development

Run specs

```
bin/rake
```
