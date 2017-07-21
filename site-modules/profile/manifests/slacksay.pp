# Deploy the 'slacksay' script (posts messages to Slack)
class profile::slacksay {
  file { '/usr/local/bin/slacksay':
    content => epp('common/slacksay.rb.epp',
      {
        'slack_webhook_url' => lookup('slack_webhook_url', String),
      }
    ),
    mode    => '0755',
  }
}
