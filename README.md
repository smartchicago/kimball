Kimball
=====
[![Coverage Status](https://coveralls.io/repos/github/BlueRidgeLabs/kimball/badge.svg?branch=development)](https://coveralls.io/github/BlueRidgeLabs/kimball?branch=development)[![Build Status](https://travis-ci.org/BlueRidgeLabs/kimball.svg?branch=development)](https://travis-ci.org/BlueRidgeLabs/kimball)[![Code Climate](https://codeclimate.com/github/BlueRidgeLabs/kimball/badges/gpa.svg)](https://codeclimate.com/github/BlueRidgeLabs/kimball)

Kimball is an application to manage people that are involved with the Smart Chicago CUT Group.

Features
--------

Kimball is a customer relationship management application at its heart. Kimball tracks people that have signed up to participate with the CUT Group, their involvement in events and CUT Group programs.

Setup
-----
Kimball is a Ruby on Rails app. 

* Server Set up:
  * It currently uses Capistrano for deployment to staging and production instances.
  * ElasticSearch needs to be installed and running for Kimball to work.
  * Environment Variables are used (saved in a local_env.yml file) for API keys and other IDs.
  * you'll need ssh-agent forwarding:
  ```ssh-add -L``
If the command says that no identity is available, you'll need to add your key:

```ssh-add yourkey```
On Mac OS X, ssh-agent will "forget" this key, once it gets restarted during reboots. But you can import your SSH keys into Keychain using this command:

```/usr/bin/ssh-add -K yourkey```
* Wufoo
  * Wufoo hosts all forms used for Kimball.
  * On the Server Side there are 3 environment variables used:
    * WUFOO_ACCOUNT
    * WUFOO_API
    * WUFOO_SIGNUP_FORM
  * For SMS signup and form fills, "SMS Campaigns" are created in the Kimball app to associate a Wufoo form ID.
  * Webhooks are used on Wufoo to send data back to Kimball. Currently there are 2 webhooks in use:
    * /people : This endpoint is used for new signups via the main signup/registration wufoo form.
    * /people/create_sms : This endpoint is used for new signups via the signup/registration Wufoo form that has been customized for SMS signup.
    * /submissions : This endpoint is for all other Wufoo forms (call out, availability, tests). It saves the results in the submissions model. 
* Twilio:
  * Twilio is used to send and receive text messages for sign up, notifications, and surveys.
  * Two Twilio phone numbers are needed. One for text message signup, notifications, and surveys. The other for text message verification.
  * On the Server Side there are several environment variables used:
    * TWILIO_ACCOUNT_SID
    * TWILIO_AUTH_TOKEN
    * TWILIO_SMS_SIGNUP_NUMBER
    * TWILIO_SIGNUP_VERIFICATION_NUMBER
  * The email signup verification number uses a request url with HTTP POST endpoint /receive_text/index
  * The SMS Signup/notification number uses a request url with HTTP POST endpoint /receive_text/smssignup
* Mailchimp:
  * Mailchimp is used to send emails.
  * Currently this is a one way connection Kimball --> Mailchimp.
  * On the Server Side there are 2 environment variables used:
    * MAILCHIMP_API_KEY
    * MAILCHIMP_LIST_ID


TODO
----
* Events
  * Invite
  * RSVP
  * Attendance tracking
  * Reminder emails
* Programs
  * Associate results
* People
  * Add arbitrary fields
  * Attach photograph
  * Attach files
  * Link with their social networks
  * Show activity streams
  * Track program status (e.g. has received Visa card)
  * Show output from Tribune boundaries service on individual person pages
* Backend
  * Terms of service/privacy policy
  * Managed access to anonymized data for research
  * Audit trails
  * Comments on all objects

Hacking
-------

Main development occurs in the development branch. HEAD on master is always the production release. New features are created in topic branches, and then merged to development via pull requests. Candidate releases are tagged from development and deployed to staging, tested, then pushed to master and production.

Development workflow:
Install Vagrant: https://vagrantup.com/
```
vagrant plugin install vagrant-cachier vagrant-hostmanager
vagrant up
open http://`whoami`.patterns.dev
```

To access the virtual machine, run:
```
vagrant ssh
bundle exec rails c # etc. etc. etc.
```

Unit and Integration Tests
---------------------------
To run all tests:
```
bundle exec rake

```

Contributors
------------

* Chris Gansen (cgansen@gmail.com)
* Dan O'Neil (doneil@cct.org)

License
-------

The application code is released under the MIT License. See [LICENSE](LICENSE.md) for terms.
