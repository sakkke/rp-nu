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
  let header = [
    'committer_date'
    'committer_name'
    'committer_email'
    'repository_path'
    'commit_hash'
    'subject'
  ] | str join "\t"
  let body = (get-repositories
  | each { |repository|
    let repository_path = get-repository-path $repository.remote $repository.name
    let local_path = join-rp-path $repository_path
    let format = $"%cI\t%cn\t%ce\t($repository_path)\t%H\t%s"
    git -C $local_path log --output=/dev/stdout $"--format=($format)"
  }
  | str join "\n")

  $"($header)\n($body)"
  | from tsv
  | sort-by 'committer_date'
  | each { |it| if $color {
    {
      $"(ansi green_bold)committer_date(ansi reset)": $"(ansi magenta)($it.committer_date)(ansi reset)"
      $"(ansi green_bold)committer_name(ansi reset)": $it.committer_name
      $"(ansi green_bold)committer_email(ansi reset)": $it.committer_email
      $"(ansi green_bold)repository_path(ansi reset)": $"(ansi cyan)($it.repository_path)(ansi reset)"
      $"(ansi green_bold)commit_hash(ansi reset)": $"(ansi yellow)($it.commit_hash)(ansi reset)"
      $"(ansi green_bold)subject(ansi reset)": $it.subject
    }
  } else {
    $it
  } }
  | reverse
  | to tsv
  | if $no_pager { cat } else { column -ts "\t" | pager }
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
