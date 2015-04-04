#!/usr/bin/env ruby
require 'rubygems'
require 'thor'
require 'mail'
require 'parseconfig'
require 'open3'

class Teller < Thor

    desc "submit QSUBCMD", "submit QSUBCMD to qsub and get completed notification"
    def submit(*args)
        # Load information
        pbapi = ENV["PUSHBULLET_API"]

        # Join *args into a single qsubcmd
        qsubcmd = args.join(' ')

        # Compile string and send to command line
        cmd                             = "qsub -b y -sync y -cwd #{qsubcmd}"
        stdin, stdout, stderr, wait_thr = Open3.popen3(cmd)
        response                        = stdout.gets

        # Output response
        puts response
        job_id  = response[/job\ \d+/].gsub('job ', '')

        # Proceed if successful
        exit_status = wait_thr.value

        if exit_status.success?
            notifycmd = %Q[curl --header 'Authorization: Bearer #{pbapi}' -X POST https://api.pushbullet.com/v2/pushes --header 'Content-Type: application/json' --data-binary '{"type": "note", "title": "Equity Job Complete", "body": "#{cmd} completed"}']
            nstdin, nstdout, nstderr, nwait_thr = Open3.popen3("#{notifycmd}")
        end
    end

    desc "watch JOBID", "received notification of previously submitted JOBID"
    def watch(jobid)
        notifycmd = %Q[ruby ]
        watchcmd  = "qsub -hold_jid #{jobid} -cwd '#{notifycmd}'"
        puts("#{watchcmd}")
    end

end

# End of script
