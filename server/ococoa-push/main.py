#!/usr/bin/env python
#
# Copyright 2007 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
from google.appengine.ext import webapp
from google.appengine.ext.webapp import util
import urbanairship
from PrivateInfo import *

class MainHandler(webapp.RequestHandler):
    def get(self):
        key = self.request.get('key')
        if len(key) == 0:
            self.response.out.write('Missing key')
            return

        if key not in ApiKeys():
            self.response.out.write('Incorrect key {' + key + '}')
            return

        msg = self.request.get('msg')
        if len(msg) > 0:
            airship = urbanairship.Airship(AppKey(),AppMasterSecret())
            airship.broadcast({'aps': {'alert': msg}})
            self.response.out.write('200 OK - Message {' + msg + '} sent!')
        else:
            self.response.out.write('500 ERROR - No message sent!')


def main():
    application = webapp.WSGIApplication([('/', MainHandler)],
                                         debug=True)
    util.run_wsgi_app(application)


if __name__ == '__main__':
    main()
