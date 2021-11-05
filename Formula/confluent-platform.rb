class ConfluentPlatform < Formula
  desc "Developer-optimized distribution of Apache Kafka"
  homepage "https://www.confluent.io/product/confluent-platform/"
  url "http://packages.confluent.io/archive/7.0/confluent-7.0.0.tar.gz"
  version "7.0.0"
  sha256 "a762ff6702f8040aa8ed01d5130a0896a8933d56ec8b84ce786d0ecf230f9c3f"

  livecheck do
    url "https://docs.confluent.io/current/release-notes/changelog.html"
    regex(/>Version (\d+(?:\.\d+)+)</i)
  end

  depends_on "openjdk"

  conflicts_with "kafka", because: "kafka also ships with identically named Kafka related executables"

  def install
    pkgetc.install Dir["etc/*"]

    libexec.install %w[bin libexec share]
    rm_rf libexec/"bin/windows"
    libexec.install_symlink pkgetc => "etc"

    # Delete some lines to avoid the error like
    # "cd: ../Cellar/confluent-platform/5.5.0/bin/../share/java: No such file or directory"
    inreplace libexec/"bin/confluent-hub", "[ -L /usr/local/bin/confluent-hub ]", "false"

    bin.write_exec_script Dir["#{libexec}/bin/*"]
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/kafka-broker-api-versions --version")

    # The executable "confluent" tries to create .confluent under the home directory
    # without considering the envrionment variable "HOME", so the execution will fail
    # due to sandbox-exec.
    # The message "unable to load config" means that the execution will succeed
    # if the user has write permission.
    assert_match /unable to load config/, shell_output("#{bin}/confluent 2>&1", 1)

    assert_match /usage: confluent-hub/, shell_output("#{bin}/confluent-hub help")
  end
end