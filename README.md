# CPU
CPU project

## 代码架构
- single\_cycle 单周期处理器
- pipeline 流水线处理器
- mips\_compiler MIPS编译器，代码和机器码

## 开发指南
为了方便代码管理，我们禁止直接 push 到 master 分支上去，采用 rebase+merge request 的方式更新代码。大致操作如下

初始化分支
```bash
$ git clone git@github.com:Steve-Tod/CPU.git
$ git checkout -b jzy #这里创建自己的分支并 checkout 进去
```

完成代码编写，准备更新时
```bash
$ git status # git add 前最好检查一下
$ git add .
$ git commit -m "Your comment"
$ git checkout master
$ git pull #更新 master 分支
$ git checkout jzy
$ git rebase master
$ git push origin jzy
```

然后进入github网页，提交一个 merge request ， master 分支的拥有者 review 通过之后就会合并。
