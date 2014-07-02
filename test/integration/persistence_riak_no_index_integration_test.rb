## ------------------------------------------------------------------- 
## 
## Copyright (c) "2014" Dmitri Zagidulin
##
## This file is provided to you under the Apache License,
## Version 2.0 (the "License"); you may not use this file
## except in compliance with the License.  You may obtain
## a copy of the License at
##
##   http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing,
## software distributed under the License is distributed on an
## "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
## KIND, either express or implied.  See the License for the
## specific language governing permissions and limitations
## under the License.
##
## -------------------------------------------------------------------

require 'test_helper'

describe "RiakNoIndexStrategy persistence" do  
  it "can save an ActiveDocument to a Riak object" do
    # First, save the object to Riak
    user_pref = UserPreference.new email_format: 'html'
    generated_key = user_pref.save
    generated_key.wont_be_empty
    assert user_pref.persisted?
    user_pref.source_object.must_be_kind_of Riak::RObject
    
    # Now read the object back
    fetched_pref = UserPreference.find(generated_key)
    fetched_pref.must_be_kind_of UserPreference
    fetched_pref.key.must_equal generated_key
    fetched_pref.email_format.must_equal 'html'
    fetched_pref.source_object.must_be_kind_of Riak::RObject
    
    # Update the object
    fetched_pref.update(email_format: 'pdf')
    updated_pref = fetched_pref = UserPreference.find(generated_key)
    updated_pref.email_format.must_equal 'pdf'
    
    # Delete the object (clean up)
    fetched_pref.destroy
    assert fetched_pref.destroyed?
  end
end