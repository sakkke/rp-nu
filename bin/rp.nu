#!/usr/bin/env nu

def main [] {
  cd (get-rp-path)
  main clone
  return
}

def 'main clone' [--no-color: bool] {
  get-repositories | each { |repository|
    let remote_url = get-remote-url $repository.remote $repository.name
    let repository_path = get-repository-path $repository.remote $repository.name
    let local_path = join-rp-path $repository_path

    if ($local_path | path exists) {
      continue
    }

    if $no_color {
      print $"\n> ($repository_path)\n"
    } else {
      print $"\n(ansi green_bold)>(ansi reset) ($repository_path)\n"
    }

    git clone $remote_url $local_path
  }

  return
}

def 'main log' [
  --no-color: bool
  --no-pager: bool
] {
  let header = [
    'committer_date'
    'committer_name'
    'committer_email'
    'repository_path'
    'commit_hash'
    'ref_names'
    'subject'
  ] | str join "\t"
  let body = (get-repositories
  | each { |repository|
    let repository_path = get-repository-path $repository.remote $repository.name
    let local_path = join-rp-path $repository_path
    let format = $"%cI\t%cn\t%ce\t($repository_path)\t%H\t%D\t%s"
    git -C $local_path log --output=/dev/stdout $"--format=($format)"
  }
  | str join "\n")

  $"($header)\n($body)"
  | from tsv
  | sort-by 'committer_date'
  | each { |it| if $no_color {
    $it
  } else {
    {
      $"(ansi green_bold)committer_date(ansi reset)": $"(ansi magenta)($it.committer_date)(ansi reset)"
      $"(ansi green_bold)committer_name(ansi reset)": $it.committer_name
      $"(ansi green_bold)committer_email(ansi reset)": $it.committer_email
      $"(ansi green_bold)repository_path(ansi reset)": $"(ansi cyan)($it.repository_path)(ansi reset)"
      $"(ansi green_bold)commit_hash(ansi reset)": $"(ansi yellow)($it.commit_hash)(ansi reset)"
      $"(ansi green_bold)ref_names(ansi reset)": $"(ansi yellow)($it.ref_names)(ansi reset)"
      $"(ansi green_bold)subject(ansi reset)": ($it.subject | gitmojify)
    }
  } }
  | reverse
  | to tsv
  | if $no_pager { cat } else { column -ts "\t" | pager }
}

def 'main pull' [--no-color: bool] {
  get-repositories | each { |repository|
    let repository_path = get-repository-path $repository.remote $repository.name
    let local_path = join-rp-path $repository_path

    if $no_color {
      print $"\n> ($repository_path)\n"
    } else {
      print $"\n(ansi green_bold)>(ansi reset) ($repository_path)\n"
    }

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

def gitmojify [] {
  str replace ':art:' '🎨'
  | str replace ':zap:' '⚡️'
  | str replace ':fire:' '🔥'
  | str replace ':bug:' '🐛'
  | str replace ':ambulance:' '🚑️'
  | str replace ':sparkles:' '✨'
  | str replace ':memo:' '📝'
  | str replace ':rocket:' '🚀'
  | str replace ':lipstick:' '💄'
  | str replace ':tada:' '🎉'
  | str replace ':white_check_mark:' '✅'
  | str replace ':lock:' '🔒️'
  | str replace ':closed_lock_with_key:' '🔐'
  | str replace ':bookmark:' '🔖'
  | str replace ':rotating_light:' '🚨'
  | str replace ':construction:' '🚧'
  | str replace ':green_heart:' '💚'
  | str replace ':arrow_down:' '⬇️'
  | str replace ':arrow_up:' '⬆️'
  | str replace ':pushpin:' '📌'
  | str replace ':construction_worker:' '👷'
  | str replace ':chart_with_upwards_trend:' '📈'
  | str replace ':recycle:' '♻️'
  | str replace ':heavy_plus_sign:' '➕'
  | str replace ':heavy_minus_sign:' '➖'
  | str replace ':wrench:' '🔧'
  | str replace ':hammer:' '🔨'
  | str replace ':globe_with_meridians:' '🌐'
  | str replace ':pencil2:' '✏️'
  | str replace ':poop:' '💩'
  | str replace ':rewind:' '⏪️'
  | str replace ':twisted_rightwards_arrows:' '🔀'
  | str replace ':package:' '📦️'
  | str replace ':alien:' '👽️'
  | str replace ':truck:' '🚚'
  | str replace ':page_facing_up:' '📄'
  | str replace ':boom:' '💥'
  | str replace ':bento:' '🍱'
  | str replace ':wheelchair:' '♿️'
  | str replace ':bulb:' ':bulb:'
  | str replace ':beers:' '🍻'
  | str replace ':speech_balloon:' '💬'
  | str replace ':card_file_box:' '🗃️'
  | str replace ':loud_sound:' '🔊'
  | str replace ':mute:' '🔇'
  | str replace ':busts_in_silhouette:' '👥'
  | str replace ':children_crossing:' '🚸'
  | str replace ':building_construction:' '🏗️'
  | str replace ':iphone:' '📱'
  | str replace ':clown_face:' '🤡'
  | str replace ':egg:' '🥚'
  | str replace ':see_no_evil:' '🙈'
  | str replace ':camera_flash:' '📸'
  | str replace ':alembic:' '⚗️'
  | str replace ':mag:' '🔍️'
  | str replace ':label:' '🏷️'
  | str replace ':seedling:' '🌱'
  | str replace ':triangular_flag_on_post:' '🚩'
  | str replace ':goal_net:' '🥅'
  | str replace ':dizzy:' '💫'
  | str replace ':wastebasket:' '🗑️'
  | str replace ':passport_control:' '🛂'
  | str replace ':adhesive_bandage:' '🩹'
  | str replace ':monocle_face:' '🧐'
  | str replace ':coffin:' ':coffin:'
  | str replace ':test_tube:' '🧪'
  | str replace ':necktie:' '👔'
  | str replace ':stethoscope:' '🩺'
  | str replace ':bricks:' '🧱'
  | str replace ':technologist:' '🧑‍💻'
  | str replace ':money_with_wings:' '💸'
  | str replace ':thread:' '🧵'
  | str replace ':safety_vest:' '🦺'
}

def join-rp-path [repository_path: string] {
  $"(get-rp-path)/($repository_path)"
}

def open-rp-json [] {
  open $"(get-rp-path)/rp.json"
}

def pager [] {
  less -RS
}
