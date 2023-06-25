# swiftlint-cli

A script you can include in your projects that allows all team members to run the same version of [SwiftLint](https://github.com/realm/SwiftLint), without needing a package manager or building SwiftLint from source.

## Install

```terminal
curl -Ls "https://raw.githubusercontent.com/lordcodes/swiftlint-cli/main/scripts/install.sh" | bash
```

## Usage

```terminal
./swiftlint.sh ARGUMENTS
```

Pass the same arguments you would have passed to SwiftLint to the script instead, such as:

```terminal
./swiftlint.sh --strict --quiet --reporter html --output swiftlint.html
```

To update SwiftLint, simple change the value for 'VERSION' at the top of the script.

## How it works

You keep the script `swiftlint.sh` in your project such as in BuildTools/swiftlint.sh. You then call the shell script instead of the `swiftlint` executable and pass the same arguments you would have passed. The script downloads swiftlint as a binary and tells MacOS to let you execute it (will ask for your password to run this as sudo).

## Benefits

+ It will download the version specified in the script, so all team members and CI will be using the same version.
+ The process is faster than running via SPM as it won't need to build SwiftLint from source and retrieve all its build dependencies.
+ It is versioned unlike using Homebrew.
+ Xcode Command Plugins can only be ran from a CLI with pure-SPM projects.
+ It is incredibly simple and requires just a single script in your project.
+ If you use fastlane you can create a simple lane in `Fastfile` to run the script.

## Fastlane

If you are a [Fastlane](https://fastlane.tools) user, you can add lanes as below to run SwiftLint in Lint or Fix mode across the whole project.

The below snippets use the environment variable `BUILD_ARTIFACT_DIR` for the output report location. This can be replaced with your preferred output location, or you could set it up in `before_all` such as using:

```ruby
before_all do
    if Helper.ci?
        ENV["BUILD_ARTIFACT_DIR"] = Pathname.new(ENV["BITRISE_DEPLOY_DIR"]).to_s
    else
        ENV["BUILD_ARTIFACT_DIR"] = ("fastlane/output").to_s
    end
    sh("cd ../ && mkdir -p #{ENV["BUILD_ARTIFACT_DIR"]}")
end
```

The snippets also use a small Fastlane helper function to print a clickable file link in the console to the output report.

```ruby
def output_directory_absolute_file_url
    directory = ENV["BUILD_ARTIFACT_DIR"].delete_prefix("fastlane/")
    absolute_path = File.expand_path(directory)
    "file://#{absolute_path}"
end
```

### Format

```ruby
desc "Run SwiftLint in Fix mode"
lane :format do
    begin
        sh("cd ../ && ./BuildTools/swiftlint.sh --fix --strict --quiet --reporter html --output #{ENV["BUILD_ARTIFACT_DIR"]}/swiftlint.html")
    rescue => ex
        UI.error("SwiftLint failed")
        UI.error(ex)
        UI.error("#{output_directory_absolute_file_url}/swiftlint.html")
    end
end
```

### Lint

```ruby
desc "Run SwiftLint in Lint mode"
lane :lint do
    begin
        sh("cd ../ && ./BuildTools/swiftlint.sh --strict --quiet --reporter html --output #{ENV["BUILD_ARTIFACT_DIR"]}/swiftlint.html")
    rescue => ex
        UI.error("SwiftLint failed")
        UI.error(ex)
        UI.error("#{output_directory_absolute_file_url}/swiftlint.html")
    end
end
```
