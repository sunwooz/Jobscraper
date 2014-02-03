require 'spec_helper'

describe "StaticPages" do

	subject { page }

	describe "Home page should have content" do
		before { visit root_path }

		it { should have_content('Hacker News Jobs') }
		it { should have_title('Hacker News Jobs') }
	end

	describe "About page should have content" do
		before { visit '/about' }

		it { should have_content('About This Site') }
		it { should have_title('About') }
	end
end