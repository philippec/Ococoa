#!/usr/bin/env python
#
# Copyright 2013 Philippe Casgrain
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
from google.appengine.dist import use_library
import os
from urlparse import urlparse
import logging

def get_pass_path(pass_name):
    path = os.path.join(os.path.dirname(__file__), pass_name)
    return path

def get_pass_data(pass_name):
    result = open(get_pass_path(pass_name)).read()
    return result

class PassesHandler(webapp.RequestHandler):
    def get(self):
        logging.info("passes get:" + self.request.url)
        url = urlparse(self.request.url)
        # http://localhost:8084/passes/pass_name.pkpass
        try:
            path = url.path.split('/')
            pass_name = path[2]
            logging.info("pass_name: " + pass_name)
            pass_data = get_pass_data(pass_name)
            self.response.headers["Content-Type"] = "application/vnd.apple.pkpass"
            self.response.out.write(pass_data)
            self.response.set_status(200)
        except:
            self.response.set_status(404)
        
def main():
    application = webapp.WSGIApplication([('/passes/.*', PassesHandler)],
                                         debug=True)
    util.run_wsgi_app(application)


if __name__ == '__main__':
    main()
