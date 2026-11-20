# send.io Ruby and Rails SDK

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Gem Version](https://badge.fury.io/rb/sendio.svg)](https://badge.fury.io/rb/sendio)

The official Ruby and Rails SDK for the [send.io](https://send.io) email API. Full API reference: <https://developer.send.io/docs/api>.

## Installation

Via RubyGems:

```sh
gem install sendio
```

Via Gemfile:

```ruby
gem "sendio"
```

Requires Ruby 3.2 or newer.

## Quick start

Create an API key in the send.io dashboard (keys start with `mx_`), then:

```ruby
require "sendio"

Sendio.api_key = ENV["SENDIO_API_KEY"]

email = Sendio::Emails.send({
  from: "Acme <onboarding@send.io>",
  to: ["delivered@send.io"],
  subject: "Hello from send.io",
  html: "<strong>It works!</strong>"
})

puts email[:id]
```

This example sends from `onboarding@send.io` to the test address `delivered@send.io`, so it works on a new account before you add a domain. `onboarding@send.io` can only send to test addresses. To email real people, send from an address on a domain you verified. A free mailbox works too once Mailboxes shows it can send.

## Send a batch

Up to 100 emails in one request:

```ruby
Sendio::Batch.send([
  {
    from: "Acme <onboarding@yourdomain.com>",
    to: ["delivered@send.io"],
    subject: "First",
    html: "<p>one</p>"
  },
  {
    from: "Acme <onboarding@yourdomain.com>",
    to: ["delivered@send.io"],
    subject: "Second",
    html: "<p>two</p>"
  }
])
```

## Retrieve an email

```ruby
email = Sendio::Emails.get("4ef9a417-02e9-4d39-ad75-9611e0fcc33c")
puts email[:last_event]

Sendio::Emails.list(limit: 10)
```

## Domains

```ruby
domain = Sendio::Domains.create({ name: "yourdomain.com" })
Sendio::Domains.verify(domain[:id])
Sendio::Domains.get(domain[:id])
Sendio::Domains.list
Sendio::Domains.remove(domain[:id])

# Receive email on the domain too (send.io then requires its MX record)
domain = Sendio::Domains.create({ name: "yourdomain.com", capabilities: { receiving: "enabled" } })

# Stop receiving: send.io stops accepting email for the domain; remove its MX record
Sendio::Domains.update({ id: domain[:id], capabilities: { receiving: "disabled" } })

# Turn it back on (asks for the domain's MX record; publish it to start receiving email)
Sendio::Domains.update({ id: domain[:id], capabilities: { receiving: "enabled" } })
```

## Mailboxes

Mailboxes are real email accounts with an IMAP/SMTP login. The domain must be verified.

```ruby
mailbox = Sendio::Mailboxes.create({ address: "support@yourdomain.com" })
puts mailbox[:credentials] # shown once; the password is also an API key for this mailbox

Sendio::Mailboxes.list
Sendio::Mailboxes.update({ mailbox_id: mailbox[:id], warmup_enabled: false })
Sendio::Mailboxes.reset_password(mailbox[:id]) # the old password stops working
Sendio::Mailboxes.remove(mailbox[:id])         # also removes an agent inbox on it
```

Sending is always on; `capabilities: { sending: "disabled" }` is rejected with a 422.

The SDK also covers API keys, segments, contacts, contact properties, topics, broadcasts, templates, transactional emails, webhooks, received emails, logs, suppressions and more. See the [examples folder](examples/) for one script per resource.

## Transactional emails

A transactional email (a sign-in code, a password reset, a receipt) is a saved send of a published template: it keeps the From, subject, reply-to and tracking (off by default), and its content is always the template's published version. Create it once, then send it by id with only the recipient and the variables.

```ruby
tx = Sendio::Transactional.create(
  {
    name: "Sign-in code",
    template_id: "signin-code", # a published template, by id or alias
    from: "Acme <security@yourdomain.com>",
    subject: "Your code is {{CODE}}"
  },
  options: { idempotency_key: "create-signin-code" }
)

Sendio::Emails.send({ transactional_id: tx[:id], to: "ada@example.com", variables: { CODE: "123456" } })
```

`Sendio::Transactional` also has `list` (`search:`, `template_id:`), `get`, `update` (pass `expected_updated_at:` to get a 409 instead of overwriting someone else's change), `remove`, `send_test` and `stats`. A republish of the template, or an update, reaches every send within 10 seconds.

`Sendio::Broadcasts.create` takes `template_id:` (and `template_version_id:`) to make a broadcast from a published template; `update` with `template_id: nil` detaches it. `Sendio::Broadcasts.get` returns `:unfillable_variables`, the template variables a broadcast cannot fill; while it is not empty, sending is refused with a 422.

## Configuration

### API key

```ruby
Sendio.api_key = ENV["SENDIO_API_KEY"]

# or
Sendio.configure do |config|
  config.api_key = ENV["SENDIO_API_KEY"]
end

# or lazily, evaluated on every request
Sendio.api_key = -> { Current.user.sendio_api_key }
```

### Base URL

Requests go to `https://api.send.io` by default. Override it (for testing or a different environment) with the `SENDIO_BASE_URL` environment variable or at runtime. A trailing slash is optional:

```ruby
# environment: SENDIO_BASE_URL=https://api.example.test
Sendio.base_url = "https://api.example.test"
Sendio.base_url = nil # back to SENDIO_BASE_URL or the default
```

## Error handling

Non-2xx responses raise a subclass of `Sendio::Error`:

```ruby
begin
  Sendio::Emails.send({ from: "bad", to: ["delivered@send.io"], subject: "x", html: "x" })
rescue Sendio::Error::RateLimitExceededError => e
  sleep e.retry_after.to_i
rescue Sendio::Error::InvalidRequestError, Sendio::Error::NotFoundError => e
  warn "request rejected: #{e.message}"
rescue Sendio::Error => e
  warn "send.io error: #{e.message}"
end
```

## Rails and ActionMailer

Use send.io as an ActionMailer delivery method in `config/environments/production.rb`:

```ruby
config.action_mailer.delivery_method = :sendio
```

Set your API key in an initializer:

```ruby
# config/initializers/sendio.rb
Sendio.api_key = ENV["SENDIO_API_KEY"]
```

Then deliver as usual:

```ruby
class UserMailer < ApplicationMailer
  default from: "Acme <onboarding@yourdomain.com>"

  def welcome_email
    @user = params[:user]
    mail(to: ["delivered@send.io"], subject: "Welcome")
  end
end

UserMailer.with(user: user).welcome_email.deliver_now!
```

## Rails and Action Mailbox

The gem ships an Action Mailbox ingress so you can receive inbound email through send.io:

```ruby
# config/environments/production.rb
config.action_mailbox.ingress = :sendio
```

Create a webhook (in the dashboard or with `Sendio::Webhooks.create`) subscribed to `email.received` and pointed at:

```
https://example.com/rails/action_mailbox/sendio/inbound_emails
```

Store the webhook signing secret (`whsec_...`) under `action_mailbox.sendio_signing_secret` in your Rails credentials, or in the `SENDIO_INGRESS_SIGNING_SECRET` environment variable. Each verified webhook is turned back into the full email and routed like any other ingress.

## Development

```sh
bundle install
bundle exec rspec
```

`examples/smoke.rb` is a live check against a real API (sends one email). It needs `SENDIO_API_KEY` and, optionally, `SENDIO_BASE_URL`.

## Releasing

For maintainers. Releases go out from GitHub Actions on the public copy of this SDK, [send-io/sendio-ruby](https://github.com/send-io/sendio-ruby), not from a laptop:

1. In send-io-core, bump the version in `lib/sendio/version.rb`, add the `CHANGELOG.md` entry and update the version shown in the console docs (a console test compares them), then merge into `develop`.
2. Sync the public copy: replace its files with this folder at the merged commit (`git archive <sha>:sdks/ruby`), commit it as `sync with send-io-core <short sha>` and push `main`.
3. Optional: run the Publish workflow by hand. It only checks the RubyGems key and publishes nothing.
4. Push the tag `vX.Y.Z` on the public repository. The Publish workflow (`.github/workflows/publish.yml`) checks that the tag matches the version, runs the tests and publishes to RubyGems.

The gem requires MFA, and RubyGems refuses a key push without a one-time code: until RubyGems trusted publishing is set up, push the built gem by hand.

## License

MIT. See [LICENSE](LICENSE) and [NOTICE](NOTICE).
