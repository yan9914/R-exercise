#���J�M��
library("data.table")


#�إߤ@data.frame���
name <- c("Joe", "Bob", "Vicky")
age <- c("28", "26", "34")
gender <- c("Male","Male","Female")
data <- data.frame(name, age, gender, row.names=c("a","b","c"))


#data.table���]�trownames
x1 <- data.table(data)
View(x1)
View(data)
#�i�]�m�Ѽ�keep.rownames = TRUE, �s�W�@��rn�Ӫ���rownames


#data.table�w�]stringsAsFactors��FALSE ,���qdata.frame�ഫ�Ӫ��̵M��Factor
x2 <- data.table(name, age, gender)
class(data$name)
class(x1$name)
class(x2$name)


#�����Ͱƥ� ���ͼW��column
x2$age <- as.numeric(x2$age)
x2[,c8 := 87]
x2[,c("age.dev", "age.sq") := list(age-mean(age),(age.dev)^2)] #�|�X�{error,�u��ϥΤw��Ȫ��ܼ�
x2[,c("age.dev", "age.sq") := list(age-mean(age),(age-mean(age))^2)]
x2[,c("c8","age.dev","age.sq") := NULL]


#�����Ͱƥ� �ۤ��ഫdata.table��data.frame
setDT(data, keep.rownames = TRUE)
class(data)
setDF(data, rownames = data$rn)
data <- data[,-1]
class(data)



#��¦
DT = data.table(x=rep(c("b","a","c"),each=3), v=c(1,1,1,2,2,1,1,2,2), y=c(1,3,6), a=1:9, b=9:1)
X = data.table(x=c("c","b"), v=8:7, foo=c(4,2))

DT[, x]         #�^�Ǭ�vector
is(DT[, x])
DT[, .(x)]      #�^�Ǭ�data.table
is(DT[, .(x)])
DT[, sum(v), by = x]
DT[, sum(v), keyby = x] #�|�N�էO�Ƨ�, ���P��DT[, sum(v), by = x][order(x)]
DT[, sum(a), keyby = "x,v"]
DT[a<6, sum(y), by = x] #���z��C, �A�ھڲէO���B��
DT[X, .(a, b), on= "x"]  #���oDT$x == X$x���C, �A����a,b����
DT[X, .(a, i.v), on= "x"]    #���oDT$x == X$x���C, �A�� DT$a �� X$v ����
DT[X, sum(v, i.v), on= "x"]
DT[X, sum(v, i.v), on= "x", by = .EACHI]    #�ھڨC��X$v, ���B��


#�j�M�l��
DT["b", on = "x"]  #���G�i��j�M����@���
DT[.(2), on = .(v)] #.()��list()���Y�g, ����K, �����[�޸�
#�M��x����"b" �B y����3��4��5��6
DT[.("b", 3:6), on = .(x, y)]   # no match�^��NA
#�M��x������"b" �� y������3�B4�B5�B6
DT[!.("b", 3:6), on = .(x, y)]  #�P DT[x != "b" | !y%in%c(3:6)] �۵�
DT[.("b", 3:6), on = .(x, y), nomatch = FALSE]  #no match���^��
DT[.("b", 3:6), on = .(x, y), roll = Inf]   #no match�N�����e�@����ƪ���
DT[.("b", 3:6), on = .(x, y), roll = -Inf]  #no match�N�����U�@����ƪ���
DT[.("b", 3:6), on = .(x, y), roll = "nearest"]#no match�N�����̾F���ƪ���



#�S���Ÿ�.SD .BY .N .I .GRP
DT[.N]      #�̫�@�C, �O�ߤ@�i�H�b"�C"�ϥΪ��S���Ÿ�
DT[, .N]    #�C���`��
DT[, .N, by=x]      #x���U�s���C��
DT[, .SD, .SDcols=v:b]  #���v��b�Υ��̤������Ҧ�"��"
DT[, .SD]   #.SD���]�t��Ƥl����data.table
DT[, .SD[2]]    #�Ҧ��檺�ĤG�C
DT[, .SD[,2]]   #��DT[,2]�ۦP
DT[, .SD[3,3]]  #��DT[3,3]�ۦP
DT[, .SD[1], by=x]      #x���U�s���Ĥ@�C
DT[, c(.N, lapply(.SD, sum)), by=x] #�HX���s, �p��C�� �B ����[�`
DT[, .I]    #����seq_len(nrow(x))
DT[, .I[2], by=x]   #x���U�s�Ĥ@�C��row number
DT[, .I[c(which.max(b),which.min(b))]]  #b���Ȭ��̤j��̤p����ƪ�row number
DT[, .N, by=rleid(v)]   #v���ȳs��ۦP�X�{������
DT[, c(.(y=max(y)), lapply(.SD, min)),by=rleid(v), .SDcols=v:b]
DT[, grp := .GRP, by=y] #�е��Ӧ�y���ĴX�s
X[, DT[.BY, y, on ="x"], by=x]  #.BY���w���s���Ȳզ���list



#Key �ֳt�j�M�οz��
data(Cars93, package="MASS")
x3 <- data.table(Cars93[,c("Manufacturer","Type","Price","Length","Weight","Origin")])
setkey(x3, Origin)
key(x3)
tables()
x3["USA"]
setkey(x3, Origin, Type)
key(x3)
x3[J("USA", "Large"),]   #��J��ƩI�s�h��key
x3[J("Large", "USA"),]   #���Ǧ��n�D


#��ƦX��
student <- data.table(id=1:6,name=c('Dan','Mike','Ann','Yang','Li','Kate'))
score <- data.table(id=1:12,stuID=rep(1:6,2),
                     score=runif(12,60,99),class=c(rep("A",6),rep("B",6)))
setkey(student,"id")
setkey(score,"stuID")
student[score, nomatch=NA]


