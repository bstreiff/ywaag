# ywaag

"you were always a girl" (or "you were always a guy" if that fits better)

This is a tool for retroactively replacing an old name in git commits.

I wrote this for use on my personal repos; you should not apply this on
repos where other people have forked them, since you're rewriting history
and that breaks their pulls and that's rude.

```
ywaag.sh -o "Old Name" -g "git@github.com:username/repo.git"
```

This will:
- fetch the repo
- run `git filter-branch` to make corrections
- push the updated repo

New name and e-mail can also be specified on command line; otherwise we use
whatever is now configured in your global git config.

Note that this uses `git filter-branch` under the hood, and [that can be
slow and has a whole bunch of other caveats](https://git-scm.com/docs/git-filter-branch#PERFORMANCE).
It worked well enough for my purposes (a set of personal repos with low
numbers of commits with me as main/only contributor) but if this breaks
your repos you get to keep all the pieces.
