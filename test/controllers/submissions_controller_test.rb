# == Schema Information
#
# Table name: submissions
#
#  id              :integer          not null, primary key
#  raw_content     :text(65535)
#  person_id       :integer
#  ip_addr         :string(255)
#  entry_id        :string(255)
#  form_structure  :text(65535)
#  field_structure :text(65535)
#  created_at      :datetime
#  updated_at      :datetime
#

require 'test_helper'

class SubmissionsControllerTest < ActionController::TestCase

  test 'should create submission and associate with user' do
    person = people(:one)

    assert_difference 'person.submissions.count' do
      assert_difference 'Submission.count' do
        post :create, fake_wufoo_submission.update(Field113: people(:one).email_address)
        assert_response 201
      end
    end
  end

  test 'should not create submission for bad email address' do
    assert_no_difference 'Submission.count' do
      post :create, fake_wufoo_submission.update(Field113: 'this-is-not-real@example.com')
      assert_response 400
    end
  end

  test 'should show list of submissions' do
    get :index
    assert_response :success
    assert_not_nil assigns(:submissions)
  end

  test 'should get new' do
    get :new
    assert_response :success
  end


  private

    def fake_wufoo_submission
      {
        CreatedBy:	'smartchicago2012',
        DateCreated:	'2013-05-03 10:35:21',
        EntryId: '4',
        Field10: '',
        Field11:	'Thusday, May 30',
        Field113:	'0000@example.com',
        Field5:	'One',
        Field7:	'First Choice',
        Field8:	'SchooooooooolName',
        FieldStructure:	%({ "Fields": [ { "ClassNames": "", "DefaultVal": "", "ID": "Field113", "Instructions": "Check to make sure this is the same email address that you used to sign up for the CUTGroup.", "IsRequired": "1", "Page": "1", "Title": "Email", "Type": "email" }, { "Choices": [ { "Label": "First Choice" }, { "Label": "Second Choice" } ], "ClassNames": "", "DefaultVal": "", "HasOtherField": false, "ID": "Field7", "Instructions": "We're focused on helping improve the process of getting to school, so we're looking to work people like you!", "IsRequired": "1", "Page": "1", "Title": "Will you be responsible for taking kids to a Chicago public school this Fall?", "Type": "radio" }, { "Choices": [ { "Label": "One" }, { "Label": "Two" }, { "Label": "Three or more" } ], "ClassNames": "", "DefaultVal": "", "HasOtherField": false, "ID": "Field5", "Instructions": "This helps us organize our work.", "IsRequired": "1", "Page": "1", "Title": "How many kids?", "Type": "radio" }, { "ClassNames": "", "DefaultVal": "", "ID": "Field8", "Instructions": "Please be as specific as possible. It will help us organize the location(s) for our test(s).", "IsRequired": "1", "Page": "1", "Title": "What school? (full name please)", "Type": "text" }, { "ClassNames": "", "DefaultVal": "0", "ID": "Field10", "Instructions": "We have blocked out these nights. It's critical that you can make it at one of these times. At the end of the test (45 minutes or so), you get a $20 VISA gift card and bus fare.", "IsRequired": "1", "Page": "1", "SubFields": [ { "DefaultVal": "0", "ID": "Field10", "Label": "Tuesday, May 28" }, { "DefaultVal": "0", "ID": "Field11", "Label": "Thusday, May 30" } ], "Title": "Check each of the dates that work for you for a 6PM meeting.", "Type": "checkbox" } ] }),
        FormStructure:	%({ "DateCreated": "2013-05-02 15:51:20", "DateUpdated": "2013-05-03 09:28:58", "Description": "If you would like to participate in the next CUTGroup test, please complete this form.", "Email": null, "EndDate": "2030-01-01 12:00:00", "EntryLimit": "0", "Hash": "z7p7s5", "IsPublic": "1", "Language": "english", "Name": "CUTGroup Test: Travel to School Eligibility Form", "RedirectMessage": "Thanks for you interest. We are compiling the responses and will get back to you about the possibility of participating.", "StartDate": "2000-01-01 12:00:00", "Url": "cutgroup-test-travel-to-school-eligibility-form" }),
        HandshakeKey:	'987987987987',
        IP:	'69.245.247.117'
      }
    end



end
