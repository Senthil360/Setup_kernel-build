#!/bin/bash
#Kernel environment setup script - Senthil360 @XDA-developers
#Under GPL V3 - Feel free to edit, free as in freedom

#colors
G='\033[01;32m'
R='\033[01;31m'
C='\033[01;36m'
B='\033[01;34m'
BR='\033[05;31m'
N='\033[0m'
div="----------------------------------------------------------------------"

space() {
   echo " "
   echo "$div"
   echo " "
}

select_kernel() {
list=$(realpath $(find -maxdepth 2 -name "android_kernel*"))
#for i in $list; do echo $i; done
sleep 0.2
LIM=$(echo $list | wc -w)
echo " "
echo -e "${C}Choose working${N} ${BR}kernel${N} ${C}directory${N} ${G}[1-$LIM]${N}"
space
a=1;
for i in $list; do 
    echo -e "${C}$a${N} - ${R}$i${N}"
    a=$((a+1))
done
space
read -p "Option : " optionk
selection_kernel=$(echo $list | cut -d ' ' -f$optionk)
echo " "
echo -e "${C}Selected${N} : ${G}$selection_kernel${N}"
echo " "
unset list; unset LIM; unset a;
}

select_tc() {
cd toolchain
list=$(realpath $(ls))
LIM=$(echo $list | wc -w)
echo " "
echo -e "${C}Choose${N} ${R}TOOLCHAIN${N} ${C}directory${N} ${G}[1-$LIM]${N}"
space
a=1;
for i in $list; do 
    echo -e "${C}$a${N} - ${R}$i${N}"
    a=$((a+1))
done
space
read -p "Option : " optiontc
selection_tc=$(echo $list | cut -d ' ' -f$optiontc)
echo " "
echo -e "${C}Selected${N} : ${G}$selection_tc${N}"
echo " "
unset list; unset LIM; unset a;
cd ..
}

set_AKdir() {
   ak=0
   if [ -d "AnyKernel2" ]; then
      echo " "
      echo -e "${C}Do you want to set the following directory as AnyKernel directory?${N}"
      space
      path=$(realpath "AnyKernel2" | grep "AnyKernel" | head -n 1)
      echo $path
      space
      read -p "[Y/n] : " optionak
      if [ "$optionak" = "Y" ] || [ "$optionak" = "y" ]; then
         ak=1
         selection_anykernel=$path
         echo -e "Selected ${G}$selection_anykernel${N}"
      fi
   fi
}

review_sel() {
   clear;
   space
   echo -e "Kernel Directory : ${B}$selection_kernel${N}"
   echo " "
   echo -e "Toolchain Directory : ${B}$selection_tc${N}"
   if [ "$ak" -eq 1 ]; then
      echo " "
      echo -e "Anykernel Directory : ${B}$selection_anykernel${N}"
   fi
   space
}

export_sel() {
   review_sel
   read -p "Confirm export [Y/n] : " exp
   if [ "$exp" = "Y" ] || [ "$exp" = "y" ]; then
      echo "KERNEL_DIR=$selection_kernel" > path
      echo "TC_DIR=$selection_tc" >> path
      echo "AK_DIR=$selection_anykernel" >> path
      chmod 777 path
   else
      exit
   fi
}
   
set_AKdir
sleep 2
clear;
select_kernel
sleep 2
clear;
select_tc
sleep 2
export_sel

