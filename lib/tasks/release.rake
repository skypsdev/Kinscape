class ReleaseNotes
  class << self
    def build
      authenticate

      release_tag   = ask_release_tag
      repo          = retrieve_repo
      release       = find_repo repo, release_tag
      release_notes = build_release_notes repo, release

      write_release_notes release_notes, release_tag
    end

    private

    def authenticate
      print 'Github username: '
      github_username = $stdin.gets.chomp

      print 'Github password: '
      github_password = $stdin.noecho(&:gets).chomp
      print "\n"

      Octokit.configure do |c|
        c.login    = github_username
        c.password = github_password
      end
    end

    def ask_release_tag
      print 'Release tag: '
      $stdin.gets.chomp
    end

    def retrieve_repo
      Octokit.repo 'kinscape/kinscape'
    end

    def find_repo(repo, release_tag)
      repo.rels[:releases].get.data.detect do |release|
        release[:tag_name] == release_tag
      end
    end

    def build_release_notes(repo, release)
      pull_request_ids = release[:body].scan(/\(#(\d+)\)/).flatten

      pull_request_ids.map do |pull_id|
        puts "Retrieving pull-request ##{pull_id} data"

        pull = repo.rels[:pulls].get(uri: { number: pull_id }).data

        {
          body: pull[:body],
          title: pull[:title]
        }
      end
    end

    def write_release_notes(release_notes, release_tag)
      File.open("./tmp/#{release_tag}.md", 'w+') do |file|
        release_notes.each do |release|
          file.write("## #{release[:title]}\n\n")
          file.write("#{release[:body]}\n")
        end
      end

      puts "Release notes placed in ./tmp/#{release_tag}.md"
    end
  end
end

namespace :release do
  desc 'Prepare release notes for given release'
  task notes: :environment do
    ReleaseNotes.build
  end
end
