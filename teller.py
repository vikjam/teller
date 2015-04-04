#!/usr/bin/env python
import os
import click
import subprocess
from pushbullet import Pushbullet

pb = Pushbullet(os.environ['PUSHBULLET_API'])

@click.command()
@click.argument('qsubcmd', nargs = -1)
def submit(qsubcmd):
    click.echo('%s' % qsubcmd)
    qsubstdout = subprocess.Popen(['qsub', 'to stdout'])
    # push = pb.push_note("This is the title", "This is the body")

if __name__ == '__main__':
    submit()

