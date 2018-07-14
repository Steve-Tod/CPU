#include <iostream> 
#include <string> 
#include <fstream> 
#include <sstream> 
#include <iomanip> 
 using namespace std; 
 
 //类 instruction
//存储每一条指令的信息 
class Instruction { public: 
 	int instruction[32]; //32位机器码  
	int linenum;  	 	//对应的行号  	
	int type; 	 	 	 	//指令类型  R-1   I-2   J-3  	
	string label;  	 	//存储分支、跳转指令所跳转的编号  	
	string kind;  	 	//指令类型 
 	Instruction *next; 
 	Instruction() 
 	{ 
 	 	for (int i=0;i<32;i++) 
		instruction[i]=0;  	 	
		linenum=0;  	 	
		type=0;  	 	
		label="NULL";  	 	
		kind="NULL";  	 	
		next=NULL; 
 	} 
}; 
 
//类 label
//存储标签
class Label { 
public: 
 	string label_name; 	//存储label  	
	int linenum1; //对应的序号
 	Label *next; 
 	Label() 
 	{ 
 	label_name="NULL";  
	linenum1=0;  	
	next=NULL; 
	} 
};  

//R型指令指令名即func
const string R_instruction[12]={"add","addu","sub","subu","and","or","xor","nor","slt","sll","srl","sra"}; 
const int R_funct[12]={32,33,34,35,36,37,38,39,42,0,2,3}; 
//I型指令指令名即opcode
const string I_instruction[14]={"lui","addi","addiu","andi","slti","sltiu","beq","bne","blez","bgtz","bgez","bltz","sw","lw"}; 
const int I_OpCode[14]={15,8,9,12,10,11,4,5,6,7,1,1,43,35}; 
//J型指令指令名即opcode
const string J_instruction[4]={"j","jal","jr","jalr"};
const int J_Op_or_Fun[4]={2,3,8,9};
//寄存器名
const string all_register[32]={"$zero","$at","$v0","$v1","$a0","$a1","$a2","$a3","$t0","$t1","$t2","$t3","$t4","$t5","$t6","$t7","$s0","$s1","$s2","$s3","$s4","$s5","$s6","$s7","$t8","$t9","$k0","$k1","$gp","$sp","$fp","$ra"}; 
 

//十进制转二进制函数
void Decimal_to_Binary(int temp,int *a,int k) 
{ 
 	int i=0;  	while (temp!=0) 
 	{ 
 	 	a[i]=temp%2;  	 	
		temp=temp/2; 
 	 	i++; 
 	} 
 	for (int j=i;j<k;j++) 
 	 	a[j]=0; 
} 
 
//查找对应的寄存器编号，转换为5位二进制数输出 
void Find_Register(int *a,string reg) 
{  	for (int i=0;i<32;i++) 
 	{ 
 	 	string temp1=all_register[i];  	 	
		string temp2=temp1+',';  	 	
		if (reg==temp1 || reg==temp2) 
 	 	Decimal_to_Binary(i,a,5); 
 	} 
} 

//R型指令的翻译 
//in为输入文件流
//name是代码的命令名
//p是指令的指针
//type是指令的类型（R-1）
void R_interpret(ifstream &in,string name,int line,Instruction *p,int type) 
{  	
	int *rs=new int [5];  	
	int *rt=new int [5];  	
	int *rd=new int [5];  	
	int *shamt=new int [5]; 
	int *funct=new int[6];  	
	string reg;  	
	p->kind=name;  
	p->linenum=line;  	
	p->type=type; 
 
 	//"add","addu","sub","subu","and","or","xor","nor","slt"
	for (int i=0;i<9;i++)  	 	
		if (name==R_instruction[i]) 
 	 	{ 
 	 	 	Decimal_to_Binary(R_funct[i],funct,6);  	 	 	
			for (int j=0;j<6;j++)//opcode
				p->instruction[j]=funct[j]; 
 	 	 	in>>reg; 
 	 	 	Find_Register(rd,reg);  	 	 	
			for (int j=0;j<5;j++) //reg rd
				p->instruction[j+11]=rd[j]; 
 	 	 	in>>reg; 
 	 	 	Find_Register(rs,reg);  	 	 	
			for (int j=0;j<5;j++) //reg rs
				p->instruction[j+21]=rs[j]; 
 	 	 	in>>reg; 
 	 	 	Find_Register(rt,reg);  	 	 	
			for (int j=0;j<5;j++) //reg rt
				p->instruction[j+16]=rt[j]; 
 	 	} 
 
 	//"sll","srl","sra"  	
	for (int i=9;i<12;i++)  	 	
		if (name==R_instruction[i]) 
 	 	{ 
 	 	 	Decimal_to_Binary(R_funct[i],funct,6);  	 	 	
			for (int j=0;j<6;j++) 
				p->instruction[j]=funct[j];  	 	 	
			in>>reg; 
 	 	 	Find_Register(rd,reg); 
 	 	 	for (int j=0;j<5;j++) 
				p->instruction[j+11]=rd[j];  	 	
			in>>reg; 
			Find_Register(rt,reg);  	
			for (int j=0;j<5;j++)
				p->instruction[j+16]=rt[j]; 
			in>>reg; 
			int sh=atoi(reg.c_str()); 
			if (sh<0)
				sh+=32; 
			Decimal_to_Binary(sh,shamt,5); 
			for (int j=0;j<5;j++) 
				p->instruction[j+6]=shamt[j]; 
		} 
} 
 
//I型指令的翻译 
//in为输入文件流
//name是代码的命令名
//p是指令的指针
//type是指令的类型（I-2）
void I_interpret(ifstream &in,string name,int line,Instruction *p,int type) 
{  	
	int *rs=new int [5];  	
	int *rt=new int [5];  	
	int *imm=new int [16];  
	int *opcode=new int[6];  	
	string reg;  	
	p->kind=name;  
	p->linenum=line;  	
	p->type=type;  	

	//"lui"
	if (name=="lui") 
 	{ 
 	 	Decimal_to_Binary(I_OpCode[0],opcode,6);  	 	
		for (int j=0;j<6;j++) 
			p->instruction[j+26]=opcode[j]; 
 	 	in>>reg; 
 	 	Find_Register(rt,reg);  	 	
		for (int j=0;j<5;j++)
			p->instruction[j+16]=rt[j]; 
 	 	in>>reg; 
 	 	int im=atoi(reg.c_str());  	 	
		if (im<0) im+=65536;  	 	
		Decimal_to_Binary(im,imm,16);  	 	
		for (int j=0;j<16;j++)
			p->instruction[j]=imm[j]; 
 	} 
 
 	//"addi","addiu","andi","slti","sltiu"  	
	for (int i=1;i<6;i++)  	 	
		if (name==I_instruction[i]) 
 	 	{ 
 	 	 	Decimal_to_Binary(I_OpCode[i],opcode,6);  	 	 	
			for (int j=0;j<6;j++)
				p->instruction[j+26]=opcode[j];  	 	
			in>>reg; 
 	 	 	Find_Register(rt,reg); 
			for (int j=0;j<5;j++)
				p->instruction[j+16]=rt[j]; 
			in>>reg; 
			Find_Register(rs,reg); 
			for (int j=0;j<5;j++)
				p->instruction[j+21]=rs[j]; 
			in>>reg; 
			//immidieat 
			int im=atoi(reg.c_str()); 
			if (im<0) im+=65536; //补码
			Decimal_to_Binary(im,imm,16);
			for (int j=0;j<16;j++) 
				p->instruction[j]=imm[j]; 
} 
 
 	//"beq","bne"  	
	for (int i=6;i<8;i++)  	 	
		if (name==I_instruction[i]) 
 	 	{ 
 	 	 	Decimal_to_Binary(I_OpCode[i],opcode,6);  	 	 	
			for (int j=0;j<6;j++) 
				p->instruction[j+26]=opcode[j]; 
 	 	 	in>>reg; 
 	 	 	Find_Register(rs,reg);  	 	 	
			for (int j=0;j<5;j++) 
				p->instruction[j+21]=rs[j]; 
 	 	 	in>>reg; 
 	 	 	Find_Register(rt,reg);  	 	 	
			for (int j=0;j<5;j++) 
				p->instruction[j+16]=rt[j]; 
 	 	 	in>>reg;  	 	 	
			reg=reg+':';  	 	 	
			p->label=reg; 
 	 	} 
 
 	//"blez","bgtz","bgez","blez"
	for (int i=8;i<12;i++)  	 	
	    if (name==I_instruction[i]) 
 	 	{ 
 	 	 	Decimal_to_Binary(I_OpCode[i],opcode,6);  	 	 	
			for (int j=0;j<6;j++) 
				p->instruction[j+26]=opcode[j]; 
 	 	 	in>>reg; 
 	 	 	Find_Register(rs,reg); 
 	 	 	for (int j=0;j<5;j++) 
				p->instruction[j+21]=rs[j];  	 	 	
			in>>reg;  	 	 	
			reg=reg+':';  	 	 	
			p->label=reg; 
 	 	 	if (i==10)
				p->instruction[16]=1; 
 	 	} 
 
 	//"sw","lw" 
	for (int i=12;i<14;i++) 
		if (name==I_instruction[i]) 
		{ 
			Decimal_to_Binary(I_OpCode[i],opcode,6); 
			for (int j=0;j<6;j++) 
				p->instruction[j+26]=opcode[j];
			in>>reg; 
			Find_Register(rt,reg); 
			for (int j=0;j<5;j++) 
				p->instruction[j+16]=rt[j]; 
			in>>reg; 
			int m=0,n=0; 
 	 	 	while (reg[m]!='(')
			   m++,n++;	 	 	
			while (reg[n]!=')')
				n++;  	 	 	
			string temp1,temp2;  	 	 	
			temp1.assign(reg,0,m);  	 	 	
			temp2.assign(reg,m+1,n-m-1);  	 	 	
			Find_Register(rs,temp2);  	 	 	
			for (int j=0;j<5;j++) 
				p->instruction[j+21]=rs[j];  	 	 	
			int im=atoi(temp1.c_str());  	 	 	
			if (im<0) 
				im+=65536;  	 	 	
			Decimal_to_Binary(im,imm,16);  	 	 	
			for (int j=0;j<16;j++) 
				p->instruction[j]=imm[j]; 
 	 	} 
} 
 
//J型指令的翻译 
//in为输入文件流
//name是代码的命令名
//p是指令的指针
//type是指令的类型（J-3）
void J_interpret(ifstream &in,string name,int line,Instruction *p,int type) 
{  	
	int *rs=new int [5];  	
	int *rd=new int [5];  	
	int *op_fun=new int [6];  	
	p->kind=name;  	
	p->linenum=line;  
	p->type=type;  
	string reg;  	
	for (int i=0;i<4;i++)  	
		if (name==J_instruction[i]) 
 	 	{ 
 	 	 	//"j","jal"  	 	 
			if (i<2) 
 	 	 	{ 
 	 	 	 	Decimal_to_Binary(J_Op_or_Fun[i],op_fun,6);  	 	 	 	
				for (int j=0;j<6;j++) 
					p->instruction[j+26]=op_fun[j];  	 	 	
				in>>reg;  	 
				reg=reg+':'; 
	 	 	 	p->label=reg; 
			}
			//jr 
			if (i==2) 
			{ 
				Decimal_to_Binary(J_Op_or_Fun[i],op_fun,6);  
				for (int j=0;j<6;j++) 
					p->instruction[j]=op_fun[j];  	
				in>>reg; 
				Find_Register(rs,reg);  	 	
				for (int j=0;j<5;j++)
					p->instruction[j+21]=rs[j]; 
 	 	 	} 
 	 	 	//jalr  	 	 	
			if (i==3) 
 	 	 	{ 
 	 	 	 	Decimal_to_Binary(J_Op_or_Fun[i],op_fun,6);  	 	 
				for (int j=0;j<6;j++) 
					p->instruction[j]=op_fun[j]; 
 	 	 	 	in>>reg; 
 	 	 	 	Find_Register(rd,reg);  	 	 	 
				for (int j=0;j<5;j++)
					p->instruction[j+11]=rd[j]; 
 	 	 	 	in>>reg; 
 	 	 	 	Find_Register(rs,reg);  	 
				for (int j=0;j<5;j++) 
					p->instruction[j+21]=rs[j]; 
 	 	 	} 
 	 	} 
} 
 

//32机器码转十六进制函数
//cout
void Binary_to_Hex_cout(int line,int b[32],string name) 
{  	
	cout<< "ROMDATA["<<line<<"] <= 32'h";  	
	int c[4]={1,2,4,8};  	
	int sum=0;  
	for (int i=31;i>=0;i--) 
 	{ 
 	 	sum+=b[i]*c[i%4];  	 
		if (i % 4==0) 
 	 	{ 
 	 	 	if (sum<=9) cout<<sum;  	 
			if (sum==10) cout<<"a";  	 	
			if (sum==11) cout<<"b";  	 	 
			if (sum==12) cout<<"c";  	 	
			if (sum==13) cout<<"d";  	 	 
			if (sum==14) cout<<"e";  	 	
			if (sum==15) cout<<"f";  	
			sum=0; 
	 	} 
}
	cout<<";       //"<<name<<endl;  
}


  int main() 
{   	
	bool flag=false; 
	string unknown="NULL";  	
	string instruction_name;  	
	int line=-1;  	
	ifstream input("input_final.txt",ios::in);  
	ofstream output("output_final.txt",ios::out); 
	Instruction* instruction_list=new Instruction; 
 	Label* label_list=new Label; 
 	Instruction* p=instruction_list;  
	Label* w=label_list;  
	while (!input.eof()) 
 	{ 
 	 	flag=false;  	 
		input>>instruction_name;  	 
		if (instruction_name[0]=='#') input>>instruction_name; 
 	 	line++; 
 	 	if (instruction_name=="nop") 
 	 	{ 
 	 	 	flag=true; 
 	 	 	Instruction *q=new Instruction;  	 	 
			q->linenum=line;  	
			p->next=q;  	
			p=p->next;  	
			continue; 
 	 	} 
 
 	 	//对label单独处理 
 	 	int j=instruction_name.length();  	 
		if (instruction_name[j-1]==':') 
 	 	{ 
 	 	 	flag=true; 
 	 	 	Label *n=new Label;  	 
			n->label_name=instruction_name;  	 
			n->linenum1=line; 
			w->next=n; 
			w=w->next; 
	 	 	input>>instruction_name; 
	 	} 
 	 	for (int k=0;k<12;k++)   	 	 
			if (instruction_name==R_instruction[k])  
 	 	 	{ 
 	 	 	 	flag=true; 
 	 	 	 	p->next=new Instruction; 
 	 	 	 	R_interpret(input,instruction_name,line,p->next,1); 
 	 	 	 	p=p->next; 
 	 	 	} 
 	 	for (int k=0;k<14;k++)  
			if (instruction_name==I_instruction[k])  
 	 	 	{ 
 	 	 	 	flag=true; 
 	 	 	 	p->next=new Instruction; 
 	 	 	 	I_interpret(input,instruction_name,line,p->next,2); 
 	 	 	 	p=p->next; 
 	 	 	} 
 	 	for (int k=0;k<4;k++)   	 	
			if (instruction_name==J_instruction[k])  
 	 	 	{ 
 	 	 	 	flag=true; 
 	 	 	 	p->next=new Instruction; 
 	 	 	 	J_interpret(input,instruction_name,line,p->next,3); 
 	 	 	 	p=p->next; 
 	 	 	} 

 	} 
	p=instruction_list;  
	p=p->next; 
	while (p!=NULL) 
	{  	
		if (p->label!="NULL") 
	 	{ 
 	 	 	w=label_list;  	
			w=w->next; 
 	 	 	while (w!=NULL && p->label!=w->label_name) 
				w=w->next;  	
			if (p->type==2) 
 	 	 	{ 
 	 	 	 	int im=w->linenum1-p->linenum-1;  	
				if (im<0) im+=65536;  	 	 	
				int *imm=new int [16];  	 	 	
				Decimal_to_Binary(im,imm,16);  	 	 	
				for (int j=0;j<16;j++) 
					p->instruction[j]=imm[j]; 
 	 	 	} 
 	 	 	else 
 	 	 	{ 
 	 	 	 	int off=w->linenum1;  	 
				if (off<0) off+=67108864;  	 	 	
				int *offset=new int [26];  	 	
				Decimal_to_Binary(off,offset,26);  	 	
				for (int j=0;j<26;j++) p->instruction[j]=offset[j]; 
 	 	 	} 
 	 	} 
 	 	output<< "ROMDATA["<<p->linenum<<"] <= 32'h";  	
	    int c[4]={1,2,4,8};  	
	    int sum=0;  
	    for (int i=31;i>=0;i--) 
 	    { 
			sum+=p->instruction[i]*c[i%4];  	 
		    if (i % 4==0) 
 	 	    { 
 	 	     	if (sum<=9) output<<sum;  	 

			    if (sum==10) output<<"a";  	 	
			    if (sum==11) output<<"b";  	 	 
			    if (sum==12) output<<"c";  	 	
			    if (sum==13) output<<"d";  	 	 
			    if (sum==14) output<<"e";  	 	
			    if (sum==15) output<<"f";  	
			    sum=0; 
	 	    } 
         }
		output<<";      //"<<p->kind<<endl; 
		Binary_to_Hex_cout(p->linenum,p->instruction,p->kind);  	
		p=p->next;
		
 	} 
 	 
  	input.close();  
	output.close(); 
}  
