cat test/test_official/test_2_o01.spl|./a.out
echo -e "\n"
for i in {1..15}
do
if (($i < 10))
then
cat test/test_official/test_2_r0$i.spl|./a.out
echo -e "\n"
else
cat test/test_official/test_2_r$i.spl|./a.out
echo -e "\n"
fi
done