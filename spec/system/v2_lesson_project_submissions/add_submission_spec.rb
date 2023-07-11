require 'rails_helper'

RSpec.describe 'Add a Project Submission' do
  let(:lesson) { create(:lesson, :project) }

  before do
    Flipper.enable(:v2_project_submissions)
  end

  after do
    Flipper.disable(:v2_project_submissions)
  end

  context 'when a user is signed in' do
    let(:user) { create(:user) }
    let(:another_user) { create(:user) }

    before do
      sign_in(user)
      visit lesson_path(lesson)
    end

    it 'successfully adds a submission' do
      form = Pages::ProjectSubmissions::Form.new.open.fill_in.submit

      within(:test_id, 'submissions-list') do
        expect(page).to have_content(user.username)
      end

      expect(page).not_to have_button('Add Solution')
    end

    context 'when setting a submission as private' do
      30.times do
        it 'will display the submission for the submission owner but not for other users' do
          wait_for_turbo_frame("project-submissions_lesson_#{lesson.id}") do
            Pages::ProjectSubmissions::Form.new(is_public: false).open.v2_fill_in.submit
          end

          within(:test_id, 'submissions-list') do
            expect(page).not_to have_content('Add submission')
            expect(page).to have_content(user.username)
          end

          using_session('another_user') do
            sign_in(another_user)
            visit lesson_path(lesson)

            within(:test_id, 'submissions-list') do
              expect(page).not_to have_content(user.username)
            end
          end
        end
      end
    end
  end

  context 'when a user is not signed in' do
    it 'they cannot add a project submission' do
      visit lesson_path(lesson)

      expect(page).not_to have_button('Add Solution')
    end
  end
end
