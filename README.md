Kimball
=====

Kimball is an application to manage people that are involved with the Smart Chicago CUT Group.

Features
--------

Kimball is a customer relationship management application at its heart. Kimball tracks people that have signed up to participate with the CUT Group, their involvement in events and CUT Group programs.

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

Contributors
------------

* Chris Gansen (cgansen@gmail.com)
* Dan O'Neil (doneil@cct.org)

License
-------

The application code is released under the MIT License. See [LICENSE](LICENSE.md) for terms.