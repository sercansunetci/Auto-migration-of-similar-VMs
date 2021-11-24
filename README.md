# Auto-migration-of-similar-VMs

This script seperate similar VMs
If you have too many VMs on one host and you want to seperate them, you can use this one
Only change the "abc" expression in the script.

# Example:
- Your cluster has 10 hosts
- You have 10 VMs called github-test-01 to github-test-10
- The script find all VMs which include "-test" on the same host
- Then seperate them to different hosts which they haven't same name VM
