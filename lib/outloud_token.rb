# frozen_string_literal: true

# The personal download token for https://cli.outloud.dev, shared by the formulas.
#
# HOMEBREW_OUTLOUD_TOKEN wins, otherwise the token the setup command saved to
# ${XDG_CONFIG_HOME:-~/.config}/outloud/token. Homebrew passes the user's
# XDG_CONFIG_HOME on as HOMEBREW_XDG_CONFIG_HOME, so both are read.
module OutloudToken
  def self.read
    env = ENV.fetch("HOMEBREW_OUTLOUD_TOKEN", "").strip
    return env unless env.empty?

    file = File.join(config_home, "outloud", "token")
    File.readable?(file) ? File.read(file).strip : ""
  end

  def self.config_home
    %w[HOMEBREW_XDG_CONFIG_HOME XDG_CONFIG_HOME].each do |name|
      value = ENV.fetch(name, "")
      return value unless value.empty?
    end
    File.join(Dir.home, ".config")
  end
end
