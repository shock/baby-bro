# baby-bro

**Github**: http://github.com/shock/baby-bro

## DESCRIPTION:

Baby Bro monitors timestamp changes in configured project directories and automatically tracks active development time for those projects.  The name is a play on "Big Brother", which came up in a conversation with a colleague when discussing the idea for this utility.  As in, if your employer were running this utility on your workstation without you knowing it, "Big Brother" would be watching you.

Baby Bro isn't meant to be used like that, however.  It's meant to be used by anyone who wants to automatically keep track of the amount of time they spend actively working on files in a particular project's directory.

## SYNOPSIS:

When working on source code, a developer is typically modifying files in a particular directory and saving them periodically.  By monitoring the timestamps of files in a project directory and detecting when a file has been updated, one could theoretically measure a developer's time spent changing code by logging timestamp changes and grouping them into sessions of continuous activity.  This is how Baby Bro works.

## INSTALL:

Baby Bro is installed as a Ruby gem.

```
sudo gem install baby-bro
```

Create a configuration file.  By default baby-bro will look in your home directory for .babybrorc.

The config file is YAML.  In addition to configuring options for the monitor, you must configure at least one project to monitor before baby-bro will do anything.

An example config file:

```yaml
:data:
  :directory: ~/.babybro
:monitor:
  :polling*interval: 1 minute
  :idle*interval: 15 minutes
:projects:
- :name: Baby Bro
  :directory: ~/src/wdd/baby-bro
- :name: Some Other Project
  :directory: ~/src/wdd/sop
```

This configuration tells baby-bro to monitor activity sessions in the "Baby Bro" project directory ~/src/wdd/baby-bro and also in some other project's directory.  The monitor will poll every "1 minute" for updated files in the directories and record "sessions" or stretches of continuous activity.  A session is considered to be active as long as updates to files in the directory occur at least every "15 minutes".

If activity is suspended for more than the idle interval, a new session is started and recorded.  Activity is detected when any file in a project's directory has its mtime changed.

## MONITORING ACTIVITY:

All baby-bro functionality is accessed through one executable: 'bro', which is installed in your gem's executable path.

To start baby-bro:

```
bro start -t
```

This will start baby-bro's monitor in the background.  The -t flag causes the monitor to output status to standard output and is useful to see what the monitor is detecting.  Omit this flag to keep baby-bro quiet.

To stop baby-bro:

```
bro stop
```

To re-read the config file:

```
bro restart
```

## REPORTING:

To view a report of activity sessions recorded by baby-bro:

```
bro report
```

Add the -b option for summarized reports

```
bro report -b
```

Add a numerical offset to report for just one day

```
bro report 0 # show report for today only
```

```
bro report 1 # shows report for yesterday
```

```
bro report -b 1 # shows summary report for yesterday
```

To view the help message and see other options:

```
bro --help
```

That's it.  You can add as many projects to your config as you like.  They will all get monitored by baby-bro.

## TODO:

- Enable reporting of specific date ranges
- Default reports to the current day
- Enable option to export reports in .csv, .json and .yaml file formats.
- Add some tests.
- Enable git branch detection and session association
- Enable growl warning option when idle interval is about to be exceeded for a project.

## CONTRIBUTING:

Contributions to Baby Bro are welcome.  All pull requests will be considered.  Feel free to e-mail me first about ideas or suggestions:  babybro AT wdoughty DOT net.

## LICENSE:

Licensed under the Apache License, Version 2.0 (the "License");
you may not use any part of this software or its source code except

in compliance with the License.  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
