# Ansible

## 実行
- ex.) `ansible-playbook -i hosts playbook.yml -u ubuntu --private-key="hoge_rsa"`
  - `-i <inventory_file>`: インベントリファイルを指定．(default: `/etc/ansible/hosts`)
  - `-u <user_name>`: たぶんsshとかのusernameを指定．
  - `--private-key="hoge"`: たぶんssh接続時に鍵認証する場合の鍵を指定．
  - `-l`: 実行するグループを指定(hostsファイルの中のグループとかを指定するときに便利)

## シェルの標準出力を出す
- [ansible | シェルの標準出力を ansible-playbook コマンドで出力させる - Qiita](https://qiita.com/YumaInaura/items/5bee47677ec903551bb3)
```
- hosts: example
tasks:
  - name: execute shell
    shell: echo some message
    register: return_from_shell # 実行結果をansible変数に入れる
    changed_when: no
  - name: show previous shell stdout
    debug:
      msg: "{{ return_from_shell.stdout }}" # .stdout に標準出力の結果が入っている
```

## `ansible.cfg` の書き方tips
- 探し方
  - current dir.のansible.cfg
  - ENVのANSIBLE_CONFIG or ~/ansible.cfg
  - /etc/ansible/ansible.cfg

- セクション
  - [defaults]
  - [ssh_connection]

- [ssh_connection]
  これはsshの引数としてそのまま与えられると思えばよい．
```
[ssh_connection]

            #実行ディレクトリの<ssh_config>を読む．(defaultだと~/.ssh/configを読むのではなかろうか．たぶん．)
ssh_args =  -F ssh_config
            # ~/.ssh/known_hosts に存在しないときに確認なしで続行(yes扱い)．
            -o StrictHostKeyChecking=no
            # compare matchするknown_hostsファイルを指定しない．
            -o UserKnownHostsFile=/dev/null
```
- [defaults]
```
[defaults]
# ssh_connection でいうStrictHostKeyCheckingと同等．ただしすでに~/ssh/known_hostsにあるホストとのcompare matchはするので注意．
host_key_checking = False
```

## inventory ファイルの書き方tips
- ssh 接続するときの情報を指定する．
```
[all:vars]
ansible_ssh_port=22
ansible_ssh_user=ansible
ansible_ssh_pass=p@ssW0rd
ansible_sudo_pass=p@ssW0rd
```

## ansible-playbookの書き方tips

### ファイルを削除する．
- ref): [[Ansible] file モジュールの基本的な使い方（ファイルやディレクトリの操作） - てくなべ (tekunabe)](https://tekunabe.hatenablog.jp/entry/2019/03/03/ansible_file_intro)

```
tasks:
- file:
    path: /etc/foo.conf
    state: absent
```

### shとかを実行
```
tasks:
- name: execute hoge.sh
  command: "/root/script/hoge.sh"
```

## install battle
- CentOS7
```
[root@master1 ~]# yum -y install epel-release
[root@master1 ~]# yum -y install ansible
[root@master1 ~]# yum -y install openssh
```
