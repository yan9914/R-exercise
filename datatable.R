#載入套件
library("data.table")


#建立一data.frame資料
name <- c("Joe", "Bob", "Vicky")
age <- c("28", "26", "34")
gender <- c("Male","Male","Female")
data <- data.frame(name, age, gender, row.names=c("a","b","c"))


#data.table不包含rownames
x1 <- data.table(data)
View(x1)
View(data)
#可設置參數keep.rownames = TRUE, 新增一行rn來表示rownames


#data.table預設stringsAsFactors為FALSE ,但從data.frame轉換來的依然有Factor
x2 <- data.table(name, age, gender)
class(data$name)
class(x1$name)
class(x2$name)


#不產生副本 產生增減column
x2$age <- as.numeric(x2$age)
x2[,c8 := 87]
x2[,c("age.dev", "age.sq") := list(age-mean(age),(age.dev)^2)] #會出現error,只能使用已賦值的變數
x2[,c("age.dev", "age.sq") := list(age-mean(age),(age-mean(age))^2)]
x2[,c("c8","age.dev","age.sq") := NULL]


#不產生副本 相互轉換data.table跟data.frame
setDT(data, keep.rownames = TRUE)
class(data)
setDF(data, rownames = data$rn)
data <- data[,-1]
class(data)



#基礎
DT = data.table(x=rep(c("b","a","c"),each=3), v=c(1,1,1,2,2,1,1,2,2), y=c(1,3,6), a=1:9, b=9:1)
X = data.table(x=c("c","b"), v=8:7, foo=c(4,2))

DT[, x]         #回傳為vector
is(DT[, x])
DT[, .(x)]      #回傳為data.table
is(DT[, .(x)])
DT[, sum(v), by = x]
DT[, sum(v), keyby = x] #會將組別排序, 等同於DT[, sum(v), by = x][order(x)]
DT[, sum(a), keyby = "x,v"]
DT[a<6, sum(y), by = x] #先篩選列, 再根據組別做運算
DT[X, .(a, b), on= "x"]  #取得DT$x == X$x的列, 再取其a,b的值
DT[X, .(a, i.v), on= "x"]    #取得DT$x == X$x的列, 再取 DT$a 及 X$v 的值
DT[X, sum(v, i.v), on= "x"]
DT[X, sum(v, i.v), on= "x", by = .EACHI]    #根據每個X$v, 做運算


#搜尋子集
DT["b", on = "x"]  #為二進位搜尋比較一般快
DT[.(2), on = .(v)] #.()為list()的縮寫, 較方便, 不須加引號
#尋找x等於"b" 且 y等於3或4或5或6
DT[.("b", 3:6), on = .(x, y)]   # no match回傳NA
#尋找x不等於"b" 或 y不等於3且4且5且6
DT[!.("b", 3:6), on = .(x, y)]  #與 DT[x != "b" | !y%in%c(3:6)] 相等
DT[.("b", 3:6), on = .(x, y), nomatch = FALSE]  #no match不回傳
DT[.("b", 3:6), on = .(x, y), roll = Inf]   #no match代換為前一筆資料的值
DT[.("b", 3:6), on = .(x, y), roll = -Inf]  #no match代換為下一筆資料的值
DT[.("b", 3:6), on = .(x, y), roll = "nearest"]#no match代換為最鄰近資料的值



#特殊符號.SD .BY .N .I .GRP
DT[.N]      #最後一列, 是唯一可以在"列"使用的特殊符號
DT[, .N]    #列的總數
DT[, .N, by=x]      #x中各群的列數
DT[, .SD, .SDcols=v:b]  #選擇v跟b及它們之間的所有"行"
DT[, .SD]   #.SD為包含資料子集的data.table
DT[, .SD[2]]    #所有行的第二列
DT[, .SD[,2]]   #跟DT[,2]相同
DT[, .SD[3,3]]  #跟DT[3,3]相同
DT[, .SD[1], by=x]      #x中各群的第一列
DT[, c(.N, lapply(.SD, sum)), by=x] #以X分群, 計算列數 且 做行加總
DT[, .I]    #類似seq_len(nrow(x))
DT[, .I[2], by=x]   #x中各群第一列的row number
DT[, .I[c(which.max(b),which.min(b))]]  #b的值為最大跟最小的資料的row number
DT[, .N, by=rleid(v)]   #v的值連續相同出現的次數
DT[, c(.(y=max(y)), lapply(.SD, min)),by=rleid(v), .SDcols=v:b]
DT[, grp := .GRP, by=y] #標註來自y的第幾群
X[, DT[.BY, y, on ="x"], by=x]  #.BY為已分群的值組成的list



#Key 快速搜尋及篩選
data(Cars93, package="MASS")
x3 <- data.table(Cars93[,c("Manufacturer","Type","Price","Length","Weight","Origin")])
setkey(x3, Origin)
key(x3)
tables()
x3["USA"]
setkey(x3, Origin, Type)
key(x3)
x3[J("USA", "Large"),]   #用J函數呼叫多個key
x3[J("Large", "USA"),]   #順序有要求


#資料合併
student <- data.table(id=1:6,name=c('Dan','Mike','Ann','Yang','Li','Kate'))
score <- data.table(id=1:12,stuID=rep(1:6,2),
                     score=runif(12,60,99),class=c(rep("A",6),rep("B",6)))
setkey(student,"id")
setkey(score,"stuID")
student[score, nomatch=NA]



