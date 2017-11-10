ME=`basename "$0"`
if [ "${ME}" = "install-hlfv1.sh" ]; then
  echo "Please re-run as >   cat install-hlfv1.sh | bash"
  exit 1
fi
(cat > composer.sh; chmod +x composer.sh; exec bash composer.sh)
#!/bin/bash
set -e

# Docker stop function
function stop()
{
P1=$(docker ps -q)
if [ "${P1}" != "" ]; then
  echo "Killing all running containers"  &2> /dev/null
  docker kill ${P1}
fi

P2=$(docker ps -aq)
if [ "${P2}" != "" ]; then
  echo "Removing all containers"  &2> /dev/null
  docker rm ${P2} -f
fi
}

if [ "$1" == "stop" ]; then
 echo "Stopping all Docker containers" >&2
 stop
 exit 0
fi

# Get the current directory.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the full path to this script.
SOURCE="${DIR}/composer.sh"

# Create a work directory for extracting files into.
WORKDIR="$(pwd)/composer-data"
rm -rf "${WORKDIR}" && mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# Find the PAYLOAD: marker in this script.
PAYLOAD_LINE=$(grep -a -n '^PAYLOAD:$' "${SOURCE}" | cut -d ':' -f 1)
echo PAYLOAD_LINE=${PAYLOAD_LINE}

# Find and extract the payload in this script.
PAYLOAD_START=$((PAYLOAD_LINE + 1))
echo PAYLOAD_START=${PAYLOAD_START}
tail -n +${PAYLOAD_START} "${SOURCE}" | tar -xzf -

# stop all the docker containers
stop



# run the fabric-dev-scripts to get a running fabric
./fabric-dev-servers/downloadFabric.sh
./fabric-dev-servers/startFabric.sh
./fabric-dev-servers/createComposerProfile.sh

# pull and tage the correct image for the installer
docker pull hyperledger/composer-playground:0.15.1
docker tag hyperledger/composer-playground:0.15.1 hyperledger/composer-playground:latest


# Start all composer
docker-compose -p composer -f docker-compose-playground.yml up -d
# copy over pre-imported admin credentials
cd fabric-dev-servers/fabric-scripts/hlfv1/composer/creds
docker exec composer mkdir /home/composer/.composer-credentials
tar -cv * | docker exec -i composer tar x -C /home/composer/.composer-credentials

# Wait for playground to start
sleep 5

# Kill and remove any running Docker containers.
##docker-compose -p composer kill
##docker-compose -p composer down --remove-orphans

# Kill any other Docker containers.
##docker ps -aq | xargs docker rm -f

# Open the playground in a web browser.
case "$(uname)" in
"Darwin") open http://localhost:8080
          ;;
"Linux")  if [ -n "$BROWSER" ] ; then
	       	        $BROWSER http://localhost:8080
	        elif    which xdg-open > /dev/null ; then
	                xdg-open http://localhost:8080
          elif  	which gnome-open > /dev/null ; then
	                gnome-open http://localhost:8080
          #elif other types blah blah
	        else
    	            echo "Could not detect web browser to use - please launch Composer Playground URL using your chosen browser ie: <browser executable name> http://localhost:8080 or set your BROWSER variable to the browser launcher in your PATH"
	        fi
          ;;
*)        echo "Playground not launched - this OS is currently not supported "
          ;;
esac

echo
echo "--------------------------------------------------------------------------------------"
echo "Hyperledger Fabric and Hyperledger Composer installed, and Composer Playground launched"
echo "Please use 'composer.sh' to re-start, and 'composer.sh stop' to shutdown all the Fabric and Composer docker images"

# Exit; this is required as the payload immediately follows.
exit 0
PAYLOAD:
� Z �=�r�z�Mr����S�T.���X���f�����*,��M�d�h�����9:�G8Uy��F�!?�y��Mw� �"	{�|U6��믿��nj��Bf@1��B����p�Z����p"�|����$��#>,p��I�(��#aNx�{�.8�M �&��l�E��R�"�R}l	[c!��*��a �9a����/݆���s���0�f�m��i�~��5����E��m�$��mn��!�m�4�wU���H�H����a)U<O����x�e �q�� �@�f�;��x�0��lX�6�(�1(��%�1��m���h�B�\k�:;� �MC�H�JH1�M
�˕R*9�.�h�f�P�۰@M��Hsqg����s=�6�熎wڑi�U��`�붦V�USU�5��,�T;�; ��h��4-�|��G��E�ں�<��C�d&�5�6N�Pp8�����(�P��֫���as�<ì!O��c<�G��S#�7̎�
y����;"-؉r7{�	\ϞsZ��ӊ�>�AҜRm��M�2�f�ϕ���*�-���ߴ�n���;�~q���)�gw݌�A	v�=���>8Ȳ+��0��ԖΛ�C���'�m)�?y��mC�-��;�v�zD�ё�3�=Wj��;=Х�Lj��d��:�p��}
>pw�@u����4t�u!/�f��_K�X�y�{�{�d
|��ߔ����A��lt������GD)*	x������WO���z�
�&c�� �n>J�~�T����Ǹ\�;/V���[��5����@�W��B����'�W���a��'k��g]�Bd��W���uÔ���oh��A!����6�ۭ�X1�׿����z������)��l���e��R���3��</��럏���� F�����d�$�E��\0�N�f��A&(�4� =k�&[P7L�kB��!Fq�vZ6�8&��x�vL���"L�6D�L��U�0�Ck����Pm���7Z;��i:Ub�
M�Q؆�YAR��R,t�aNڜ^	�?MU�nѺe�j�( x�hbL��7�e�W�˪f(-�	�V{�24�t�E��V��dk�ܪ�j� 4��ڥ���h�b}Aw��H^ƣF��N��kHWT�I0	�?�����lHS�+�������f���rb9�2�D�ڛ����������iI�^V\ ��?J�?����������
���@�<Pwt��vڠ�j�z��mtND�tt]�#���Y��y����0G�����B�c���g�Zo�4y�c	���e��������4����m���Y��+�6���(��2SWq��x��_�0��"i���Tk�%uR�5�����Q/��z����B��hĴ���x�-f�-7�a�p�c�%���1i���}mƐ���a��d���d���g�G��?1�]������.LA���vI��b�j��{�\�QmZ��^3�׾����0G��.{�!h!`!)6�5U�	*ـW�eܯ��S:9��v6b�^G ��9K*c�1��T��G���Xqz��p#*H��g�ʚ��]N/�b�����q��!��5/o��a<t��^:����������d"ݛ�����X���*`m���a����=ձ`����3a�����g%��Iɑƕ�\���L��4f�a7cª+�9�I�M?��g����'�&Ly/[:/%�٣��/xkB^1���슞b���ч|�EX��r�
�i9^�&ΏS�R�0���z$5{2�P-���_`�rڤ7j�_��U0^`�*d�f��41E�	lm�gaf��r��RY.����\�R����4�y	<�����F�J���"�hw�o�@���M���x�lN�x�O`�D��{0�H�l9���ǒ8�Ӯ"��~^R��,����1�[�$���y;�gF�����㳈��ΰ����&�E�.s,���Ht�������p��ժ����S;`�t"���:���y5P7�6�rA^
r xڸ��M�E��h�>0L���iߧ�h��ynR��J�������<�T���iU��i ��C]���2��k�si���'���{�7�i���^,��,5�����"�p������z�W��e.,��p������`}��&��)��:V�M��4�蘪n{�v�5+�<���G6�u�x��1#{��8����o&
~���-5���(훾Kb�"9V߲Q� #�=��"��)ӛ��U:���r9�u8cfn�LX$��|���@�Iوyb�A���?��o�bQ�jM�bt�'�G7�B?�*��E�QC`̭����	�3�\�3�;�Bנ��֦=�`M_�\�����̥�E�T������������?(�d�\��x!"6l�{)��S|�}��kAfDJ��@�O�=�� ����_�w�V�޽K�����0�Y���?��]��\
Y������Ea-���o�?��ϵ?�b
RZn����5������ �y���1��}��܏���Qo>��0;�7 {-H��GL���/=�\Q��{4�9����> �t�srm��� ���:1�
C�j-PE�O4�wo����E5ˍ�|�J�c��͆=��*3$��G�F�fM�E�<���$)_$�Acz�a�O��j o��i�u�������O u��@�nw��:�z����}��f��^��GR>�a�`�n����e�Ϝx�Qxϖx�L>2VFd_���{�bʋOM}�c����9�=�1V����x�&����w�K]�}�f�{-��f׆�f�83�Q1{,�S������><�� 
M]m��E0M��W��E�&�9DW�B����F&f,��l���x^��ʡh�Z��v�ۮo�P]��JL�(�K��䔰�)�ߎ�X��B��(Eϭ�H�+��R:Y+��$3�Am0��a4����G��t� _��ݎ��!+�SJ��<��n` Й�rA�� ��6�}x_�h��h"�4ӏm��Sx��[#�g�� �e�3�M�����KO�z� �i�z|�RJ�X�{5ҽ�Q�en�	��փo-���h��'pk�/���"��!D"k��J��LP��ĉ�?A��k�%��Wc��E[m4m������+F�b�)2L1����w��?-(l���Y�� �e4���Qa}�o%�����]�!���O�C���Jm@W��c�벤>E�i�0�D�A�Q:S6 ��+�Y�0�J��o�4xM�Q�L�И�}�^���n�{\%^��Z���,V�YO#���xa�޸3�6���z��Z���5�G����ߧ�E���������<��M�ݞ���:� �y������_I��+���eΙ��}����������+��'ΟF�*���ۮ+�1X��Ee;�ԫ1⬃H�c�XXT��b1�ݖ��$m�Ƿ̟�e&	o�������h�s��f�;�/�����M�I�e���7�q����	6J�������7�D�����aY�wԤgm����}������&��0�_��Xy5���x���f���)"m���8?z����s��w_�T½Sw����z�_|��-巩c��/��?��K������GO����Q5�Nj�_!!^�,�c�A���o,ν��&���G���T�������(˺�p��G�����L6�*��&�r����s�l"s�H�J�!��q��-�y�P?�?��B�L�xU�TK+����q����R��\�0����J*��%��s��+�o�1�r��oV3Z�~����e�B��yJ9y���x杮��Ω�]�
ۗ�����0ʩL�v�r��4��7q�$]T�r/)C'WN	��;��=���T���_d�\9����	I��i� �~r��
V/Q8M
�T��q�*U��#�K�s�!m����Җ:���I.^p[~�˿�+B�ɦ���'�|���^��8G1�^�pR��$��s%IC���d.��v�[-��pO�s�x�C��cr#�I$��Ԟ�e�x��޿��L�T��h��z�r!ّ$b�u|O?h�G�b�~
���4��TU�EϢg�^r;_�f�\��9S�L��Q.�r���s[K�R�P�@�x���s������\�N���KX�U�l���%��l�m�A'��c�t�x����?t�xd���%ґ�*����,wr�1l���5�\�����_����Ƈj����*&��BM��y4��PI?��c�D-��6J�~�h�_�kF�Hu`*��ŢN���8�w9��c�n-_)ʻ�t:�S��e�^__C�����8P���1����������G�����g��i�<�E��R���ٽ;@����m_Ê�������y^Z��|r���S�4�1��f��,�;����U(48.�;8��j(������١|̕�7(�9Ѵ��N"媸_���E��,�n�*T��N�ҺJ�D��ձ�Nh��*j<f��V�_(J})�!�r�'d�F�y�W�)
H��JV��Ar�̡6��F.��|7��{�ˁe�� �Ա`��0���$Ik�o%0GOb�U��e�$fY%�YVGb�U��e5$fY�YV?b�U��e�#fY则�13U�_yL�]����ě�����V�M�s����kx�e���O\���J���U�ل_�K�z���'�%��P�K�%Yh�)황t���׹˓��x��сG��c�8L��s�R����8]�5C6�;���A�����.��K�]r����(gaRn����I�>w��v�ֿ�VT����:���{�������u��J�	H��I��������i�H�,PDt^Ԃ�e�|8p�(����*2w����0F�`j��zh6,@�U]��F�D����6�a�\���V�n��'�ɒ�����K���*x ���?�>���ц��|�4���&�R)tK�+w�AiF�������W����qCY�6| ����B�7w�"�{�YL"�d
8y����t�6���;������Wtrɂܣ������/	!V5��(tI��T/�"���:����sjǤ�*@� zS��V=��Ǵ�k�e���腻]
�l� �4M�'�D̗m��´S���I�}��ڽ�g�ib\GҚ���3�y;?<���03o�����OZ;v���:�N8�ʱ����؉��z�.;H���{�
���@�� �����'��y=��"1M��\�U�Wߟ���>����P<~{o��H�AC=�����#R`�G?�P�OH�-/�Z�G!89�3s��ƃ*���)(���M�60hB�g�+8DC p���*p~�!��wu�M�������<�'���#�˥�'O����&�ѵ6�?��38AB�9 ���\	����'�T�&��檱|tg���۫�7MX���E1��>,��·;���út�N�kÊ��ZAWQ< ��׹
#dXg�d0��|uw������/д3�u\�MB!���$�(��&�T��X���b,=���@��.r�a�C�W��E���}�U	��9�)��:�*��/�(�Th�X�p��>qC��x�8��XQ�&���Λf��3�]�D�=��� &�U�k�ѣ����و�N��!%��B*=cfA.��F�Jʦ=��y"��d�z�6U5۝�˲�q/JtT�=ԯ����{�a�8��Q��!�Hw��h5����dP�f(�j8��'𫀖��X�#��c���s��|��"�J�^=��S����`;E��OM�hDx�[t�K���h�jh�Nb{eW��S�xl��G������B>��}2^�<��?�����S��ߟ�e��h�s�����g��o���7��s�w(�S��E,�_�{�͗￶�#|W�uu�Օ���H�3qE1��+�TZ�pIӲ��j*���T"�L��tRMf���}���J~I�r�~��O~��>}���~���W~��,��g�>��I��1⻱�o�"��6�������#�}{������[�E��~���#�"6k����^��?��7G��5�CW���1�:���\I�2�ցm��E5i���c�XM;Ϫ�z�c��::&n{v�����������̘�//D�C�3bwEF�;�Ee���Yg!�Փ�Y���[V��(.r+���w$�8�Ć����ޙp��b�e�������g�"�P�BBk�KyT����\l���+�ο�(���6�ȅ֬Cgm��8��~Q9�4��+�`���i*�a��ph��Ғ)��A���n�v����:�Vve ���a��䫥z�Q<��`��W�M�ܙ��F++&���1�C�l�jL�e��Za$2|$^���N�`���p�,��[���W������յ����kE��gs�GD��tf"5�'�����yb���k@�F�r��Y�h��l�h�l�H��r+5=�&�������<�rB��赒)0o7[v�)�3�|"����N���*�D�/f��f���߻���t*�ҩ���S	�U��f��#����T��e�&���A�v���D5��يJU*ݘ�ȍ���Q;k
\�m��XH�|�C�B�ع��!���8E��t��������럓AUK�ƱF!]��,]>�R�����m��;[�`f�Ez��
m��I��ω��R�|$��P���)E���d=u��!|��,�'�5��A��&b�ȶ��|uR�-#Q��l�P��"����~�\�~�Lq��V)b��)�%�ZҩZl�s��N[���d�.e��0'0'�43�JqH�|�zt��Z�VuګJ�ρ���ύ�Ԉ��˂�������_�{9�Nd/������n�z�_� ���{���ᛵn�xˋ��C/�(R�i�e���{_���c��Nԫ��k�����b0�Hd����+���\�,�������މ��׉�!W��_��Ǟ����"?���{�sT�g׊��
�2�u�`g�U����^V�t�$��{t>�����sL���9z��{N�,�$�c�E��j���%q�9,�Wt�^�D�coK��m����o�B!��Җ��z��ص�Y�A����n7�uvE��Y*�*p���?��T-ў)�U��b��)�X��z)&7�՞5)8���`�L��:�K�.LJ�&�q����R&�u<Vˠ�K$.��j}g8��X�A´s�N��l�2��,�t��/��i�s(�K��o��6#t�+��P�Z��p,��~�.����LI��htL�$�$��T��Œr�n��-�G@#D�1�Yu�OE�X$��;���Y)�	�ьN�Bz0�����k�&�e90��RTZ��8+��L�ji�AcuA�O���o�����򶁜_1Ǿ�̍*_?W��N��"�YV��e�.+�	���ʜ�3��;q[~�ٝ�6������Pn�z�f*��B�J�ՙb[z;_��0j��)XҬr����qS���ö^oM��*?��(�v�i��Y
�\�ׅ3�蹳a�[aR��y�"���2"㸆2��9�a�#�Y��\�LFk�b��굄�勋�f�g�����Ӊ=���ֹp��
%�nB���0`D0;�djj�{������R&|����6��8�|q�hH�a4NJd
�B�+��f���ұ�fv@K1*FK�z�̔V���d�ŵ<Q��"Y��X���񉞞�T�-+/X%�̽XEb:�S$��o?�m�`Ă��	q�-_�k;�Je�똯LȜ�
~�^�4K�x�u�;�M��Ѭ�D-yd�G|v�b�	���~��̻������@�P�`��N%�d�2UI��y<(čUf6׉�j0E�
��5���n�;�y�����WP��5v�Zi-֓g*��qSbbQڒ��Ba�AYofXJK��uy1���q��J��IvQc�#"a�I�2����[Q�:�E'6#���®�b]>�%�������f�3��U�إ�]� �Mh�٥_��6݂Ft`7޼M|m2߸Q`�qϳE�eOu�T,��W����Ϣ�\ul�,i9Q#oF^#^�L���?��7h�+5�V��=�ͧO�R�>}Ju�I���Hn���W#�����>_c��10tō!�E� �0�еQ�<}@�Y�@k����`�L{���<?���x���s6Ũ����ZP] ���Q��jY�IF��z�O�t���w��V�������|��-���?�����/�\s�K�/��I����/�s7��H���?���BO{�����8��������N�J�8�B`et�,�;L���EN��T�7�DD.�k*r�3���7#� <�&�i��-�����>������[�:$?��p�W��Qa#u�f[����nO�4t̺���a�E�����9r ]s�c�;���B �@M���zWD�t]�7�и�u�<GȀ����� ��X����D>E����� 7 ��)�]��*z���f�/��Y070&��H�p�+�ㅫx�NHR�Ik`���Pg�I!�.���_����g�/������2aӐ'�K�v��{�G?�����9\4ܣ���B�o,|�j�Gvꝫ�9�N��x�O�1�����G�A8$�P�Na1���T/pX)�����ۊE���u�75/��t�A;0�!��J�Fʦ��+)< h�"��>b�4����It-�mX���>�!�0!D�Y�A�U��O.'�/�^H|�@\��䰺1����W��];ؒ��m��������>�A��5$|�djZ����/��-��=�����|S��4ZZs�y��a�&��������b	$4buao@s=��,b��N�D��(&��i>'	���е���3�pBi�6x�OB�xl��9��6�%�w%k�سumpݍ�q-�@���S^1�6\7N��]E\
���������p/c���#�>ڗ��>��C�������Uq�^�ל����.�� �mw�`��<�Ё�h��m?�$v F*�2j���BI�ڄ�6R��5���am9_���q�ps&��k�ƆFRtۆ}fG`��f�]@�u:�SA����c�4�	9!�gP��n٥����/�د�j�'���[�E ���T����z`��"����u�͐"][_�b���&���>>���7Eil�8]1�����zĞ�P!ӄ�m ���l��`�k�$)�<�0r���0�3;5�H=��|�p�)�0�c`���Keb� U��3�
�C�7plڛ���ז�������:�Ʋ�ZR�/�y��?D�_t��$�+4��֑ND���-���-t���ƪ�ӡ'76-��.��@H��U B��Ũ��"���7»Z��\o��/j����.�8���k��'�t|;�[<M}���">^��C�C�C�@$��\�dG�%WV�#�Hw����Q�����u�aB�4ǜ��H���݋���䎆M�q�7з
A�,��U���Y^(ߠ��[�e�z����<[?��Џ'S2��Lgi$�j<�O����ڧ�t������,��}��M�D"�:PFc�0��B���Q�-7�.�r�A�t��~�=��%���M�{�Y�X� a.̡�|6�Tȩ$�e9����
P(ZM�b  H�Y5ˤ2j�
J!�����H�H"�|(����߉C>T���sh����={����t6�x�)O�{r��V��^������p���fl[mp|Ru����|Z���1_~���L���Д�
�q��|��U����ߦ�y�X���k��f/���kWL*ǔ�fM���Ǯ��2^J��!� H��7�S��D͉�L�������ۃ��i��Zm2��b��WF��qa��}�L}tmT{�m;?M`t"\�uC���$����͔�I5���yA�Nk<��"t�<Wd�J�ʭk�<��l��Y�X<�+\�*T�ǳ��8�F��ut���l��V��0}▨�SH�W�����v	6����ظj�6-V�R�Z���
/���#���F��K���n���!y�,u���x�gЀfY/�`ۦ�R��#1,����Yo��W��U[�"�zs�~���|��fϕA��-�E%=��;������KX��\$�o'����":ܤ�/��7�|xo6���vs��:߲_�d�X��0tE��c�:]��j�y$���O���W�jq�ؖ8[+��oM�;�Ǟ�e��v�T�(:R�V�)���:~��o��ޕ,'�m۹��͉(�7�q�BH D��uу�����,C��v��dz�A��p���ݭ��=`� ���_M
�?��H���<�����x����I�$����o8�=���<�X�sԭ�7	��(����|���{�F �����y�	p��"_����W���*���Ke�_�����q�����H 4�@4�ԁ���O������	P�8��K8�I��bD]����(�0\G~(	"ƼH�&d8�	V�2�)����e������!�gx�V���/$�N��\���럋Ie���t�^���Ɩ�z�m�ay9e$�}�錳�st�y�s\�Z�-?��A�&zc|�V}&�[��#��c�~:���K�ùj���x�K��t�P)Ň����馺�~������?8����/�����!e�N�}�8����I��(�����?�������e��/������&��	�?
����N��߂/������n�?��� �Ž6A�=����K����������B�(:�����di���)��( �:aU'����[8?,�u���?� ���������Â�����D���a>���s���'��H�Z��\��x������SQ�W�ESj�\6����織���R�����'����c�հ�=�y�$�7�Y��ͬ��7��<�I���Ǌ&��Y�8�͓��Z�i�U�t�ˋ�v��L��S��m�"��Z�����< ��Z�>�Զ8��n���"7�_��|�$~f��狭��I���}O���%�5�b�f��c�֧�x5�L7[��s��i7�.��\�zb��Qܹ������lX5�Bm|6[�D5�E��x�0t�yW��D��	�^���w���{:�L,q���?-i�����i�@�=�B
�@�������Ҁ��Kj`����`�7���?���?����4�?�@�ei��e�����������?���G����/A����!������j������ޑ��q.Ox�4�E�����\��e�����?���7�,��a=�Z}��i�7BE���p�UV�rg�].A�\M�-���F*��Y)ؖ�IA�gIW�Ɛ�����6d��W]޶-={����l��C\�?���,�cH?ST�0��?���s��e|����1�M6�g�0I�f�9O�bm��ӹ5v��(v�n�uҕS��;2|�?IUVQ���TOT��Xf�!�'���k�������
,�uG�Q��P �7�OY����� �����Á�����/��#N�MJ'�$OE���ȑ�$1��a(�!�3>/�4�$�!�HL@�$��y������!�G�_����[�9;�ʺS�Um��֙x؝��f)K�P4f5k�M������b�lwz��~�y�n�O�fO��:1����|t�8�p��.W�d;AK�DO5��ꐝS���M5�z�_u��5����������P���/��[*p��!�+X�?������y����e�_8�?���W�{��{{S�V�DH\b�u'������������f!���z���-�o�5�TS��Oߔ6v��3�ꔘn���c�yBv���k�?p+�E�4&�J�.������e�d���� �{+��i�������+������ ��`��<������A��_��Ѐe �'7��"	A�!�k��;_�_����$l^We?�/GB�Qz��7��Ѭ���=���V݌����Gv ~` 񽞽��"U��`��J��.xu��&k��7�j����^�sr��&D�R�*f�0Z���u�n]=�t%����`�d=����m�ɻ�7g7��|��%^X����w���%\}�^�z���kJa)�x`�$zM��OB��aa@���F5I:�]?-�s�k��yI$�(ڣ6�3�훙�&��3���Z[)od���V	e����B����&i���ZU���s�T�c����x����'���d�vKN�Y,Ucw��T���rm5�a���b���O�^��Nd�p�{G����P����Ї|���_������C�
���4y����H�����[�������� ������/��������D�Q��Ɋ��E�lH����<�J�@��3~]�A�MG��BL���`����N�/'@�	~e������s�������` �G�.ة��g޶ص��O��nWF�D�\��ά�ʨ{�~���K����ޤ�b7j��>u���i��r�](�>������Rk�S%֫�vm�Y֠��������;� �����W���_%�G@q�����4�������?��!���e
�8���l������!r���?���� ����;-@�^���C�[���o�v�U��i=ҵ>_87��Ṕ�oM����uڞ���>F|���Z�&����(�ΰ��CN�_�V<�����^4��C��G�g֭�`�ұ9�q9�M�a��T��|8��d웲Y�#7M9K�oSh��
FfE�.������SZ��։k-W{�z��m#���έ,w��C��]�5/��v�t�������x+��\����mWv"[z_5��L�'T=��q̊�Y�Ru��*�fp�����tP�jb$.g���<E��Z���QX��w���jt|2=��$"�ߕ�n�F��E���ߒ�F��~w\����8�������$��h�8��w��y��� ������������>O��R X�����p��������#dp���_���������˭�ߙ�&A���������G�~���@q������ ��I�6�g��Q ��o��k�l ��������,���`Q2����K�����$�����D �����ܝ�/���x�?�C�*��Y��� ����~���G����0�0R" ������n�?��#�����C�����$ �� ����?迒��C������Â���_��0�@,��;��? �?���?��C������H����������_[�a������?�G������������C�?����!��������?
�
`����)�׻�� ����8�?�� ��'�����X��	
"C�Q�'!����L�P/F>^x"�)Q�|_�Y���}�'�������%����5���L}�����S��T����8NB�F�j)�:�J�<�	�-H��v}�X5-�]�Y��iW�UY��j��������5_*��T�J';��ON�;q�E����&�t����^��i?��Zji�/cŚ�-�[hw��~�1�?������|U�R����_y������4`������%,�������!�+�2�넌�+y�W�*+sC��$V�Nt��/�g����W�S�׋繻w��ʶ+=z��Q��k�d4%	{��$>Rǚ����{%�u���xs������:m��T�dLc�mW��T�l���
<������E����+������ ��`��<������A��_��Ѐe �w��������|����������\u����;r��AT����Z���ߣ��J;M��Nm��}H���ٴ����V+�a.my�m�7AB6(���`;L�F�]�<P�V2��n�Ͱ��3~&�Ϲ��0�m��V�o�3�m�|;��낸�v��靾z�=�z��w�5����ga�$zM����l��i_nT�����@��:�f����!��=j3n;�پ�����;���A+i��DS�h0��_=��u�&�~/UꭹgʩbtGC����6�(�/�J$��:�4F\%�o�yu��p���ϟ;+�A�_�x��
x�o��Ҥ@�����_$�����������O����������o$�������xa����ϒ	��8�?MR��_������'xz�T�������߅�y����k�?���rt���aه��Y�RaoQ�Ҋ�>c�T��@���5Mv��?T�e�t]�3n��O=�J�{�~X��!�G�w��sʏ���s
=y����ԥo)�s�{M]^3�W��{ےaO�)I��i5�oYWKQ�kC��\1N�ꦒ����\������|���<���s\#��s�����,�c��)y���E��L���,�)!���5%���~,ъ����?~.�..�Z(�X��,kr�9�G<�r��ӨZ��g"�'UTE�ƽ-SQ���\�1��V��4Ն�Uf1}�1�Y��{�eN솬)��*�����B%l�s����P�z�h$;�aI�����[I�DI�U_)����ˠ���;g�ӫ�8�</Jn[[��?7��,�w���_D@����#�b�@��K�҄	)��0ˇ҄di��'�P`i�3B��\HƁD�1RLvp��o��/�����W��k|2�^�7:i�HB���xt��l7���IDO=%~����+߫�=r�V��������5����w��C������V�A�	|�!�1P����?���������Z�k�����3r���e��Q�'[�#>��7�?��6����:��r������v?�#��k�xC�od)���_�9����#ޖ�s�4w�r�jaϫ|��m:qm��a�3����^�F0nT�%��Rs��0�ԋ��r&N��Ѳ�LRc�\�~�{�~�i?�N����o�J��Ĳ�w~�����	��E,RG{" B��ML��iHH���>�J�iK.�]N��{"lˀ�y�w�y��ͱ�i�#C*��"Ä��nY�<�3q�ZV��Nl�����S���N%Z��f�cC}ʐ�i'QL�R�^�Y�"i�{m�����������֋�Ӝ��:�jrk=@���X�_���<�?�V������J�5R��r�JF� �?��?Q���J)�RV�X�F�u���S�B�T�/WJ����H���_�������g���5z�I��)�v��CE���F�@��FM`{��j�S���eK�Z��-���R������@�C������b�w��0�i ��_Ija��\��?k����2��m `8(7H���p������T��>�P?��؛�QYmz�]�)�����Y�k���?�Z�|�h~9�xbǗy���u1Q@>q�:J����^
�vuul��x�|^V��,/��e�
�ѡ����8u咝=^K�+u�����Yx!�}N��i�{"vý����.1���=�W{�3��M���ؽ��ON�J"\���󨿙Wp�V�=��:e�_��y���m���^:�b�����y�G�ŲQ�<���^$��9�Z�k���l����\�"3����[���h+�M^�������=�b[ʮ�M�]]���zm���P0�:9�(�yK���!k�fuH���d���-kh�1
�A��Wuǈ!ߣ�r��+�7�i�A�������T�F��)���߷�����O�!M��D��!��u�'C@�w*��O����O��������?րC@.��}�<�?��g�����r�\��W�o�j�O���o���o����5����_Y�%�kH���Ob���\�?s����)!��J��!' ��Ϟ�o��B�o*Ȋ��~��� ���=��U���������������?yc��?���"#������/���T ��� ���\�?�F�/���,��d���[���KW�������P�r�_�?���� ��������A�����"{@���/����!'��!����C��0��
����������� �?� K��&��g���[��������
������r�C�f��������E.�F��OF�R���c���v�����_���_��0�CJ��k4��:����h�`�jT��ea�ʔ�3e�HZ3���k(R�*S�1���֣��#�_�����O���n_�aQ�!�.�TcM�mq-�;n�A�����x��s$�8	���o��3i����S��U�㐟!�ئ��5��T	�kxc3�c�o��d�z�r�N� ��٨H����sS9tH|�Bڼ������J��)�5�uMQi�᤹S�:��c�2o�FgXYaU�n���N*��3�����U��a�7�C��_v��C�OvȒ��?���Y_��E����3�?N1[���]b�N9��F1�h�?�ڦ��uxf�˝9\⿆0^u��p�Q5��c[q������;$&�`�_���~�cڵ��n�hQW8�ZCi��.�GY+�7�&(�b�����G�_��ߌ�e��)��+^Կr���_�꿠�꿠��@�e��0C�B�Q���+����7���_�������t��Qے������O�X�Dn.ឺ�Ё����6�yo��,�r���aTg0�;�6p'�:^tTgZd�q��F4)n� 3ȩ�z�X���t�m`J�ض���+)=eW-��ߥ��R�r�K���9�?��"�V�ţ����m2}�D��U����F��W�G-8<�Q,�|���P����B��\�!�4�k>��gO�����I���B�:���Mu�F��8�ʡ�#�X>� ������=h�G$����;�t��$L��
�o���9��p
����k��O@�GN������v��Qb�O��x}����_�H���><���6!{ ��g��v��)��O��R���s ��g�������I����I���������������� O�.��#-��>�ǘ�	��H������x�ȅ��o����K��?�2S@���/��?d���?L��	r��������o�����S�����a`s]nrlLJ/���C�[��Eb��#�k?��
��jW��ɏ!��#)�@^P�;mq�K�o�R�{��@^V��+����N�Xcv4O׋U����R���d�XT6x���duV+��;��F��Fյ����0'٠lLNӍX7m٫���_�G�~/e�ȍ�_EN�cQ�fG�T��E�	�ݲ�y8Vg���&�<[��r���q՝J*>�F��ǆ��!W��oM�R�^�Y�"i�{m�����������֋�Ӝ��:�jrk=@���X���0ȅ����̐��{6	x�����}�\�?��g�<���G�H���o�a0��
�����������I����O��g})��߷���S�F����: ^���!�?3|+��V���g�����mԬ�ڎT���5�R��������H2/����鯵��x)S�� ��?k ��`+V�G��:��e��h(͸����u-Y����ReJ=@9ܻe�zTgA�j��Jh�V��Ζhˊ�5���k �����  I�� �#6곲9i��VE��.��j�\X�D;ud�e�Q�Ġ�w�{���x���ʦ-F�Z��6�����P+
]��jL�^;R-�������_��+d��>N����O@���/�_�o�?����@~�������àM��}Q�T 0�&U�"�����5S�0(MWZ��bA���z~e��o��	����g��9d���&��ڜ�=愌%�4��
���t��ԍ����J�2��xt��؛E����̶wB���Z�iEɑ�%Ei���:}*�Dqyu�}���bRC��T0��� ��Ŗ�p
��yh���3;d��'�@e}�yh�!�����������$�q����K��!��?3��&���Z�jW�s�C��T&K����Pl��q�������Gj;n	��d��s�5�Gx�1�/<�15�JcF�Ctql;�]��{u=�H�F:�G�k7���hӃC���h���D�A���ȼ��� 8C�"��2�A��A�����˲�4`6ȃ���迌�-�7I����MK�艳�(QĖ�p�Ŝ���{������j ��D �k �+3�)k����+�6��F���NQ��%��J��SY�%m9/3ᑦShmJ�z�22N��lh^PWkxy^lo;�z�s���2It��Q�����s�ь�z�%}����F"��/��[:�����˒��zY�y=`�-����)iW��������(\y?4�����l�s!=�k�-?�E��@��CNV�ۯ���'i<3�N��,�:1b�ks~lCÍd��o6����*�*aӢ��d/4�D�R���[�fd/�*�_N0~7�[n���^/�����o�?F���3�'H�D���ssn�N!���J��=5��>o���&fԃ��aAd����E�C��޿�N��y����细���ӓ�9K)���
��]��Bn�j������y^��&+�x���8���������w���Ol��Y�.�����}e���OޒP|\�X�����i:�� �$�xAc�`$��i�o������J`!��
���S0l?���?�o;aAY��7f�8��	���N��ߩꡮū���N>�|a�|��v����d�dϒ���������xۏ�v�#R���߼�GA[���_|��7��>:�>/�/���)������^�E�)�+���������ێ��m�wa�HB �u�w������<7��k��v��
���GJ|]�/Ԏ���������T����of;���5Η>(DVL|��ql�,�cz�?ރ� ���	y0d��C�%tF���^+~�K�n���� �f�������w$X��յ�ѝ	�|�(�|��1�Z��u{p}�?.�l_�λx�n����(,&�/�9�ܨj���⡗���'[wm�k�_�g'���Y��<��>t���5��(K����A$� !��܅_�R���]�er���/O��L�����.�(             �&��a � 