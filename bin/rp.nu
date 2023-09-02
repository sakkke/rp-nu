#!/usr/bin/env nu

def main [] {
  cd (get-rp-path)
  main clone
  return
}

def 'main clone' [] {
  get-repositories | each { |repository|
    let remote_url = get-remote-url $repository.remote $repository.name
    let repository_path = get-repository-path $repository.remote $repository.name
    let local_path = join-rp-path $repository_path
    git clone $remote_url $local_path
  }

  return
}

def 'main log' [
  --color: bool
  --no-pager: bool
] {
  let header = if $color {
    [
      $"(ansi green_bold)committer_date(ansi reset)"
      $"(ansi green_bold)repository_path(ansi reset)"
      $"(ansi green_bold)commit_hash(ansi reset)"
      $"(ansi green_bold)subject(ansi reset)"
    ]
  } else {
    [
      'committer_date'
      'repository_path'
      'commit_hash'
      'subject'
    ]
  } | str join "\t"
  let body = (get-repositories
  | each { |repository|
    let repository_path = get-repository-path $repository.remote $repository.name
    let local_path = join-rp-path $repository_path
    let format = if $color {
      $"(ansi magenta)%cI(ansi reset)\t(ansi cyan)($repository_path)(ansi reset)\t(ansi yellow)%H(ansi reset)\t%s"
    } else {
      $"%cI\t($repository_path)\t%H\t%s"
    }
    git -C $local_path log --output=/dev/stdout $"--format=($format)"
  }
  | str join "\n")

  $"($header)\n($body)"
  | from tsv
  | sort-by (if $color { $"(ansi green_bold)committer_date(ansi reset)" } else { 'committer_date' })
  | reverse
  | to tsv
  | if $no_pager { cat } else { pager }
}

def 'main pull' [] {
  get-repositories | each { |repository|
    let repository_path = get-repository-path $repository.remote $repository.name
    let local_path = join-rp-path $repository_path
    print $"Pulling '($repository_path)'..."
    git -C $local_path pull
  }

  return
}

def get-fetch-url [remote: string] {
  open-rp-json
  | get remotes
  | where name == $remote
  | first
  | get fetch
}

def get-remote-url [remote: string, name: string] {
  $"(get-fetch-url $remote)($name)"
}

def get-repositories [] {
  open-rp-json | get repositories
}

def get-repository-path [remote: string, name: string] {
  $"($remote)/($name)"
}

def get-rp-path [] {
  $"($env.HOME)/work"
}

def join-rp-path [repository_path: string] {
  $"(get-rp-path)/($repository_path)"
}

def open-rp-json [] {
  open $"(get-rp-path)/rp.json"
}

def pager [] {
  less -R
}
