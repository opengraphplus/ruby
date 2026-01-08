# frozen_string_literal: true

require "spec_helper"
require "fileutils"
require "tmpdir"
require "generators/opengraphplus/env/env_generator"

RSpec.describe Opengraphplus::Generators::EnvGenerator do
  let(:tmpdir) { Dir.mktmpdir }
  let(:api_key) { "ogp_test_12345" }

  before do
    @original_dir = Dir.pwd
    Dir.chdir(tmpdir)
    FileUtils.mkdir_p("config/initializers")
  end

  after do
    Dir.chdir(@original_dir)
    FileUtils.rm_rf(tmpdir)
  end

  def run_generator(args = [])
    described_class.start([api_key] + args, destination_root: tmpdir)
  end

  describe "API key validation" do
    it "accepts keys starting with ogp_" do
      File.write(".env", "")
      expect { run_generator }.not_to raise_error
    end

    it "rejects keys not starting with ogp_" do
      expect {
        described_class.start(["invalid_key"], destination_root: tmpdir)
      }.to raise_error(SystemExit)
    end
  end

  describe "env file handling" do
    context "with existing .env file" do
      before { File.write(".env", "EXISTING_VAR=value\n") }

      it "appends the API key" do
        run_generator
        content = File.read(".env")
        expect(content).to include("EXISTING_VAR=value")
        expect(content).to include("OPENGRAPHPLUS__API_KEY=#{api_key}")
      end

      it "skips if already defined" do
        File.write(".env", "OPENGRAPHPLUS__API_KEY=old_key\n")
        run_generator
        content = File.read(".env")
        expect(content).to eq("OPENGRAPHPLUS__API_KEY=old_key\n")
      end
    end

    context "with --envfile option" do
      it "creates the specified file if it doesn't exist" do
        run_generator(["-e", ".env.local"])
        expect(File.exist?(".env.local")).to be true
        expect(File.read(".env.local")).to include("OPENGRAPHPLUS__API_KEY=#{api_key}")
      end

      it "appends to specified file if it exists" do
        File.write(".envrc", "export FOO=bar\n")
        run_generator(["-e", ".envrc"])
        content = File.read(".envrc")
        expect(content).to include("export FOO=bar")
        expect(content).to include("OPENGRAPHPLUS__API_KEY=#{api_key}")
      end
    end

    context "with no env file" do
      it "skips env file creation without -e flag" do
        run_generator
        expect(File.exist?(".env")).to be false
      end
    end
  end

  describe "initializer creation" do
    it "creates the initializer with ENV config" do
      run_generator(["-e", ".env"])
      initializer = File.read("config/initializers/opengraphplus.rb")
      expect(initializer).to include('ENV["OPENGRAPHPLUS__API_KEY"]')
    end
  end
end
