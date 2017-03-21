tmux:
  pkg.installed

vim:
  pkg.installed

duplicity:
  pkg.installed

python-paramiko:
  pkg.installed

# To solve "CTR mode needs counter parameter, not IV"
# http://nongnu.13855.n7.nabble.com/CTR-mode-needs-counter-parameter-not-IV-td219261.html
# http://duplicity.nongnu.org/duplicity.1.html
python-pexpect:
  pkg.installed
