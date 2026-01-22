# frozen_string_literal: true

require "spec_helper"
require "fileutils"
require "tmpdir"
require "generators/opengraphplus/install/install_generator"

RSpec.describe Opengraphplus::Generators::InstallGenerator do
  let(:tmpdir) { Dir.mktmpdir }

  before do
    @original_dir = Dir.pwd
    Dir.chdir(tmpdir)
    FileUtils.mkdir_p("app/controllers")
    FileUtils.mkdir_p("config/initializers")
  end

  after do
    Dir.chdir(@original_dir)
    FileUtils.rm_rf(tmpdir)
  end

  describe "#comment_out_allow_browser" do
    it "comments out allow_browser line when present" do
      File.write("app/controllers/application_controller.rb", <<~RUBY)
        class ApplicationController < ActionController::Base
          allow_browser versions: :modern
        end
      RUBY

      described_class.start([], destination_root: tmpdir)

      content = File.read("app/controllers/application_controller.rb")
      expect(content).to include("# This blocks OpenGraph requests from consumers like Apple, LinkedIn, etc.")
      expect(content).to include("# allow_browser versions: :modern")
      expect(content).not_to match(/^\s*allow_browser versions: :modern$/)
    end

    it "preserves indentation when commenting out" do
      File.write("app/controllers/application_controller.rb", <<~RUBY)
        class ApplicationController < ActionController::Base
          allow_browser versions: :modern
        end
      RUBY

      described_class.start([], destination_root: tmpdir)

      content = File.read("app/controllers/application_controller.rb")
      expect(content).to include("  # This blocks OpenGraph requests")
      expect(content).to include("  # allow_browser")
    end

    it "does nothing when allow_browser is not present" do
      original = <<~RUBY
        class ApplicationController < ActionController::Base
        end
      RUBY
      File.write("app/controllers/application_controller.rb", original)

      described_class.start([], destination_root: tmpdir)

      content = File.read("app/controllers/application_controller.rb")
      expect(content).not_to include("# This blocks OpenGraph")
    end

    it "handles allow_browser with different options" do
      File.write("app/controllers/application_controller.rb", <<~RUBY)
        class ApplicationController < ActionController::Base
          allow_browser versions: { safari: 15, chrome: 100 }
        end
      RUBY

      described_class.start([], destination_root: tmpdir)

      content = File.read("app/controllers/application_controller.rb")
      expect(content).to include("# allow_browser versions: { safari: 15, chrome: 100 }")
    end
  end
end
