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
docker pull hyperledger/composer-playground:0.13.2
docker tag hyperledger/composer-playground:0.13.2 hyperledger/composer-playground:latest


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
� �D�Y �=�r�Hv��d3A�IJ��&��;ckl� �����*Z"%^$Y���&�$!�hR��[�����7�y�w���x/�%�3c��l�>};�n�>԰�DV@ŭ6�Q�m�^�®�{-����@ ���pL��S�B���Y#R.Fä���BpmZ <r,����x˞�J��,[��6x&=�8Y]E�6���M>�o�uYL�B�ç�ނuR�赑e ������K1�6��#	@ <���m��+CfG���B�3@J���҇�A!��n�� \?Q�Uhi6��N����5�@�2�a�SB�ė�\2��	��"d)ZK7��iaà+#�B�X8��өE�H%��4��ݤ1ـ��w.���O��i�7L�:d�-\��x�M�FV-]]4|٪��oA�����:bPXD�!U��:�"�&�C��`�����l
�,�FVQ����]���K�9,�!����5�?�CZ�eЮ׭��
�������#؎	a��S��g��P=���&jP��V�n�R�΁U���E��b�e8����&�Wa��㗗�Ȁ?gԟ?usd�l�{Z_}t����ǖ�Rf�t�i�a�R2��N����60]ø��Q�s&r��j2���t�z�Y&4�d�v}�q��m�?x8��N�§�{o�:y�Xd��Ga��I�@�D����#���̀/�����"n}ڍ����?2�EI��	��e���di����|��f�
�gc�R��>���i�E5&�|�Pʻ�G�d���σM|�=hw5�)����8�Y�`]�k��Oe�.�g�QZ��*`-�_6̐�6T�����66�v�'�=�%!2%�ѵ�_�M�p�{��r�D��B0�N� ��,Pfe6p0�3�9G6��-�W� ��q;m�]����vۖށ�c��Y�<�l���������� �lhɓ�[�����3Jc�����)��4�5}��kx�3t�6k[!R�@�?���IdG��v��XÃ^V�6����66\:�6��{���$�aUg�W�z�o��������;���F�=�A��C����h�d!R��J�O�`<88O`�����=����{D��z2�Cj�AT��M���?�0R���]]�%��D�N�Iy��W���P/�\�����@Sj�"�X�i�f}�R�憕l��orWw(�<}�1m>nrz����H<��v σ��(I���60��H{�6$�^o��{�G"���X?e���ƥ���x����Kt���oҬ�� �h�}:�����Yco�l m�E��p�<6g��N��?L���{�uX�=�G C�1�'�ccxؙ�&v�9�YV����>n�>U��a��	�_]��>�9��v�>�X�6�O.L�]�a�h�5L>���(�;,�w�CAHu@�����g~<�}�w�3��6و�g��?�<m���|B=�&]6��۟�����F�6�������d��
���`�ի�T�CDoj^]���F�Ѕ���Ȇ*�a�-�
3�?e�{;��p��h$&���*`}��e����=��D�EY�M˿�>�]x~Rjt�yg��;�!��1��Qw���Qo7k��礹�E)�A�l��T���	ꄫ�����R�3�Mȯ&�?��]��<{z5��F�Ĝ��%�r3J��K~8N�ʹ����m���	���5m�$N���h^�����k`�U�!�F�i�t+����#�Y�S���rE)U>Tr���Qe~�'�f�]���6"��ٛ׆0Q{G�xc�~��v������E�~޾Og6��g��B��{0ܒ0�rnW�A����n��,���􊹥@�u�,��N ��J���_��*�?.��lAP�I.�#6C��d���NΏ軋5���'	����X�_6���A˹��2��´����
���|����l��n�1�-T�/�������}�u�3��_�{��ߏ����:�s�|���N\p���o������%(x���O�8]�������4݅c���-�Ȳ���-�t���45;��x u��G}���N�'�B�RJ����2�h����(���D�l��:���}��%=��O����AF���!߉^dd�~J���J�bA�6UB/�z/�Ign�L�H�;�N��*4h����'V����=��:�
�M�/�����L臱�Xt��5&^+����S6��;�S�t�O����@54�.�on����������p��k���pw���#՚+����"����K!��B�xz-�h��8P����mf bP���Ux+l���T��ު��:Qe���T���L�#rtJ��Hx-�+�_���G��2��z��a'�� ��S|�k���_��tS���K����i��c�u��J��� ������vg��~H���V@���=dt��`,�j��@{UNm�P �48���$ �Y�hh�ڜ��nU����G�>Ȁo8k�'�7u�f<[��%W�%0����l;^�?��4�O�1��c��̿�	}�f��H�Ȱ1�hf按֧�e�J�1Qa,��P��<��=ȧ�3�,ϟ2/W�X�>,<���Q2��.x4�ML!2}�Ԇg%�nl�W3�������<���4�'�q��1&����U�����<�t.��Ax��_!�>��D�u��J�������o����������5�S�營P�*��,ŷj���r֪5Y݊ǣ�j\��D�����ò
�x$����T݊D6��k�/_sӄ7����Ni���/���6�������G�>�$6ml9������6lT��}��&���W�|5�����Y�;{�_6����mp���H��}"8sb�ͫeo�a�1A��a�8N	�h�1�`����f}��+����y��j���?,���j���n�&m,�������Bx��WW�k<�(�j�)�4YH�Mҗ<������<yz=��d)�}��z��������Q�!�
(��5��j[qTS����0"<�Ҡ��eA��Vƫb�8��H�4��]�*"j�F� N�B"��@2]��2��RI��wf>�KfϓIEM֕n.��s%���ǅ=-���𛘎�M��M�Os{�,wy.�	nW�L�
J3��G�D#�<>�_�/�R�^8&�*�f�Q��j��O��s��{�VR�䙞Ⱦ3�V�=���Si�"[Q�x����{g�i��M�Q}���ʑ�$\����+i��xg�fbvwj!_Q��󜔯䄃JN:�e�L��3O��|��&����b1��>>�LW�d��蒉�^Q���䬣�"��J�$�(z#��ޙGR�ͥ�z�'�s��p^�L��	�a(��I�����B��̗#�f5{a�
�j%qFf2��&z��W��l2��w!�$����E�(f��J��wb�7����yĉ��<��*���~��8f��j�pO��@���|�,v�
�X��k��虜�e�ݽ�J%��Wd���Z��N��E�ƻ����s�[�'��VZ9W�|Ҧ��r�b3��Sr��u�X"���3��~�����n	���KHf�y]z�%\��<Y��"ԕ|�(�+&e{�}g&�����)���e<r5̳�T.����Q�8�Ij�z�^��Eq���N�a:���cn����8�{���㱎V8*);�L���Bj���~?
�~��f}_7��c��?��S���9�Q�����ԟ	�cg޲�R�D�W���}>��װ��_��O��	�bd���K�cb�^���>���.���"��
]H}�b�.���~b롸ެFsgʱPߠB��0:F&����^є�q���R�:I�xT(��G��L�^\˭��_TQ�1'7�z�R��(rt�+e�z�qba�V$$AU	����~j�"�J�8�|�-���}�Y���/�����dm�W������=�5<�e�i��_��\	�����~.9n�3�n�{��$���($��T���a�k�3�#Xɼ�_��ݐ-���6<l�s� s��7�HuKgo��L)��X��mqoo�y�N�T�⾭w/��n۬Wr0��wv��t�>���v���v0,���`��W��z�wD^�\<I��Y,.2�ȓoV;� %Zf�b|��'4��0�&�諒xg�5Y�`���������xHV��A �PM7u1�k4���%;��A��N���QK����r�]��i��%N��< � (��� @
��nn���*V~�mS�|��T��e� }�@gT���,��9�%�~�ް��~�nێ�A>��?#�{c.��m��<���e^F~Ĺ��;F�ȤA�4��i�LG�L�ȄUû:�.h�����c!�H�YA��O�3Ԯ��*@�� ��6���]h�\J�T�>蠗�4z|:l�� 4�,أ�B�/�ґMh����h۶N�DP�.�T�/oO�$��%�����bTL��6(���д�|�tуct�dΰ�����2����B�W��G�g���5DUϐ�$к�_�7�u����蓄�'fl!�WW����� ��qr��/$�禭�k�}2�h�d�5�Xg蘇��%�9���m��۔�:����Ǵ����0&ez�[�xR2'�����\)F�#��q����� ���L1U`Y�`����RZs�/N�$���q�pwt/zR��T4Z�B�*a�f �:�i5�\6z>A�xp(��Rb`�$�&���M�ZU<I�N@��)v�������G{�,!x�*m���v�|E,󵩡�L�o���aEߥ�OZ��ɱ\���SQy>X����0��nd�=eH'�&�n��K'�(�pm"EDW��&�*v>=_�{��i�^�P���F��rM�e�N�V �C���Շ�X�Ul:����8�2�〷l�^�>O��o�Ȱ`$2D��d>�>���������/>�8�,��C���2��Զ����>k5�I��x,��zĆ;�@K6џ�[G&��v�����6��E9,L�������]	p��޵�:�������"5��`�P�t��T���I.SR۱�87��y��rb'q�<n��I�X �h����;$f�����A,X �X���#�㾫rk�9��u�}��������G�P�K�G������_~{�����I�犁���/��?���o>�������8�=Y �q�����u�#�~ܺ�.&T����T(�	��!9BEk1C�HS�1�")���cd�#H���8A�m)#��I4��گ�×�o��ԏ����?����������~C��~�����+�����}�6���~������C�kB)����/��!���-��oA�C Z� �b��E��t3׍F�ǆ���R�M��O�N�����K��%@W!��W��*ć�jL�.�
�QU\K`F6k.�u��"�3�J����%M��\�H�א�g�Y�{�)a_�i�Vi�"
E����9f����1�-��+�f���R�����0�m����	ž�0a�Sn�X�o�3�J�^��f�<�1C(�f��7���%rw�kT#��Su�����1�<M/���9�T��a����~�/�l�/�cM��N�҅j1u�o"�e"����ss�$�e��Hv�l[H`&�Y��t!�2�����@��1���G��I�I�?h�5af��\6i =[�c9+�9�S�$%C;��\'E�T�ϥ��H�fw�f�6Zd��~�;>ob٢Ue��;�Ť�j���%�#�<��屚)S���8��[_�f��8��i�2II�j�l��0J��MJ�͍��+"��B��������<��+��.�K��K��K��K䮸K䮰K䮨K䮠K䮘K䮐K䮈Kd���`�E�,�h"��IR���QJ,P;Ǟ��f5/Ƙ�������Ŷ�!�E��(p.T��|� �sՃ��B�~kՃ �s;�5SV�=ܼ�5S�S?��j��2OM�X1IOCs��7�l�P#��Xn��,��b�ї�2�B-M���Vy*�(K�F���X�6����Im�@]�~W��D�D#�}�caLBbe.;[�r���S9��-M��y�u���'C�f�XG�\"F)� LvH3�3e�L��NL]�!#��~��k�=c�l�O(\2wZQ�r����򈌵Y��o��Y�p�p�wa�.~};�G�>޲�}��Go��[����V7��_½7v���ϐ���-�8��[���HS[��'�w��8r����ɇ:�kP���^<�Eo܁��՗7o^�:pQ��~ z��A�߾��>r~��G���0�����?�ރ�q�(�,-Q&K+���YN�U&�TY.R�Qr����%�E��K�\�'6��e&l��r&	XJ.�6V�`)OWr!������EW��:��2�M	\��+�s@��-�(U��N�Q<�RØ �Y�F)U`�x"�Rq*}̎�J�W@bT>\��ʱ��0�YO�,�PO�-���JK'Mc��z�]]��tG������HM�s���BղTw%�f-��t���f��`D�*�!-�l��2qFjrˁ��hG����q�r�RrtnI����'J�n����%}��)�N6E�G��ZS�|-���ny0�����"�~-gY�l�}�/�-�2B:B3��1���q���nXS��a����a��Z	�,�H��=����d�80����\��Q�/
�4�ᢙ�ޙv��-�?~���,0���3�rbIW\�d��~D<�b�5V�B[_d{�"��Ymd=��g��̬������m��ew��=��tϲ��fU���S��L��=���j"o�:����zR��J�-�%%�A��U�P+�e�φ��Q��Y4b���:/�yzU�>���T�~��
��C�+�@����نr\�i��f�/����Ts�u
�0�I�泎֞G���SkO'�:����J'�L[��dUX,�]Z����Z4�$%���Ų<�ҥ�,�0�6o�����Ţh1L���d*���S*�E�vk�0����4�c�/��hzYxv#����䉬�b�H��lPkjd*�1&#w���e��Mv��dd&iG�����!�=��&T&�m�`\e����K��dm�\eR漫P���j�RJC�r�u�V�sH�<ժ.6�X��u�]%��F��wny,�qI�c�z%#�g)�\U�ɐ��Ng*]v'@��V� �F١P"�L]<3���Ҕ���B'=CS��;A�RXH���S(�ͨ�(�w�i�МOqR�T�H�j�y����F�
>*[;LF-�c��ul*���Ps���ʆ���h���R��r�e��٥��]���oY6�#�]�n����"<���eB+��څ<�����-ZTtc��_�Gn�G���,8�U��Tc%� ��>�F^����0���ԥx/���������ϟ�<�BށyD�QR������ʳç����"i�l�����kz���+�7O#R�B��ZgdU� �qD�7�'���q��!9J��t������u/;�<p��剢� ����S:��u�^�^f�y����n���������0]���B[��!���o����6��'�~0�u�zd�v[�~'אn��;�0�JP�^��`����[�t&ê$=8�&�@1��ؑwR{G���}��rF�������>G�&����W����]= �;�9	~�amT���!�G����y�tu���}f]/���u��+Z�Zu��^���9�щ��z�|.�vL���������"�	:Y�G�	j� �G�~����( �h#��f��D��Z7 D� FW��BE_�oL���v����4Zcp�X�x�,Υ�`�7�zw4���P�t v9�����=_ͩ�� ���|�V�ت���ć��I�I��,�QСwA���9��
Zt��?_} k���������*Ù:��^�5�>蜯6��Dj���Y�A����W���_��'�N\l+Mv�dt��9��u��5��*��:	�]BG^�WĀ��Mt����X�Nl�Z&��C/:��VB ؆��:l�cI;	GV�'0\Y-j%�ȗ[/$�̀\1�ces�7�ןzP���f���	�v�!a?�Z[�o�ŦB�.�Y������Hס����:�n��CG�[� :l*DO��a�7�rMg��[�܇>��Ih���X��F��Q`[����$%�I��4�\vu�J]����EP�͖�Z��P��b�	�l} �u�dM"[W���6���	rO�;��y�6��� @�+�K%��D�Ꙥj�e��~�%CL����K6��i�nd�����+Nx�h��v�b�c��� �<�б�~��
"�G.j�P)�ea=���� ���R�������e 
�9� \�U導5�"̓�]֏�Hsu0�j��v�L�P ~��{(ܤ�S�B����Mk���n�2Úd{�����6A.��~d�xk��^���fK^uqձ�+�4a��4��߻<���Ŗ�/�A�}l|��۰�-��V}5Z�;-B$�E����[�d��v��|x�]M��SgFN���Zf&�>PV�5U�t���H�P>fu\�뾊�9�;x� �?�Q�#c�6q���8y���9'1,F�$��r�c�]���v��$����l(�D �n1����+��0Ts4�;rc�R~��qC���~T��S��Q�b��];����^s��u�s���7W�q��2Bl��$C�p���V2�'�'H@m�VɎ������N�d�mxV��4S��gq�D�x�*F�Y�C�;
��b�+�߲�UŎ�"]V
|<K�k4�ڵ���8�}:V�h蔫߬� d�"�&!IM2#�)!�MQ�VKi�r��K�Y����n�c�G���3�o2��|���+v��̉�cY����V����o����)*�r�Q�Xo��:���fU�1�I�R����Q,"K2N(�&�$I��pL�`Q*����BHH!k&�1%Qp��kb�O�v���sl�ȟ�٘Yv�@�M�S��{疄�\w4�8����{r���ʸk_�����Wp���m��rE���\�+ҙ�L.��*\晬4�����%���,[�J�g���s�K|I��T�}���Ⱥ��ܓ�.�]2�8�Jy�}�;�*7�t�Յ�>vϺ�
��{kGv&��t46��������vT�;mBZ�^�u�uT�`t�e���;�&�m2u�k-����0Q�:����Y��> �M��\L�[Q>/��x��"O���Y�����S4����UN�'X�)'׳V�3.��s|V|6��E�=kt&M��t��VOu?}��3�"/==��u��لGK�}cs�S�h*W�l�O�e9��+�
�螹lt濴������ۙ��v�yZLm���,�E�ؤU�$�"g�di�f��,B���%��r<�2Θ���	r#���h��2���ӣ��g����gmIӕX__$o���=":Y�����54<�Ew�n��X�[����+��]V��P��Vw�y�� �ȥ�����w����wǊ�[�q�2g�b�jb3p(�pTtz}������]/���,�K��"��/�Hw\�m��ƍ�?d���a���^��o��۬������Gz%�����o���{����-�6aCii��O��/�U���m�2>��}�}����O�=_ٴ/���_���������^��������@s�,}��J���_�o/i_��"�$k�V�(֎Deܒa����Rd��D�BE�h;�
��P3�*MLV�0!����E�_��*��C�m���%���0�7�i��k��P�#��NS��qEl��)�a�|��B�����'��?�*��T��5�A�ͥ�3rX)D��H��ȟV�e����R7BҲ>o�㧓R�ޛt*�IWK�+!,��j�:�wǨ�^��'K;���*��������/�ml�}��v�}��m��q�p����*��q�:��}�}�����=��|:�������u�GF"���t�� ��{
��� �����?�>�9��{I����Wq�pJ��t����򟤶�?u���H����~?;�D���%�/��	jK�����}�C��C��C�Οh��+a��;���޵u'�n�w~�~w����a�q����x�e@DEE��G�X��N*U���S�J%��d��֚����?߅�2@����_-����� �/	5��� u��)�~����R�V�o\��`�m�S�z��ڍ}��:�-�\���,*���5!��Z��O�gv?��!ZG����u����g���Of��������'�2p��
�Ze�P�ga=�m�^3�j�[�i��X���-�q{����a���E�j�G��Ǡ=���7R������'�#{�mwo�L;�^>X��ݮ�K勄���2Iν�f5_�[�o�>��nٌ��^��r����Tшz6�k�))f3_�j��J{�6E�Ǳi�|{���ԣ��i�کJX2b�5v�����4�����e���{Z�@����_-�����^�)Qe�����'��.���O���O�������@�eQ��U�����j����?�_j����	��OD����o��[����^�['�:��=?�qU5�h@ۉ���[ٯ��?��/e}�GgM���y��?t�i�S?)^��C1�­�7�õb"�K�X�]ZqR._3j#'{���9&��n��1='�Sa票o�7CZ�59{*둿�����S]/?�����sI�D#W�/m|���o߼����,x���N�#*���q�]��&��`3]��)�tBЛmm�&�}�D����5IA��+&:ܨ���:�)�xv(.i��>5���W�B�a����@���s�Ov�� ��������ī��S���KA��6�0ƟS��GilF��G�Jq�������4�Ҍ���>�SGxh��?�:�����������ϊ��.O�����N#Y���]���5�5�c�Y���6���K����3ss$���'/#��d�>���62]���jrG�,�B��#�Y(G�d���$3/m�T��6Ó��:���^�����ա���>��o������P�����P���\���_�/�:�?���W�ݐ��*7��qȄ&rp�s�O9�^�v��Y:�ҧ� K��O�t_��1�~��.��ݶK�2���œC�������s����a��uN�?2��d��
�����ߊP�������~���߀:���Wu��/����/����_��h�*P��0w���A������S\�_H����-�npXO��I��H>M���g�J��~v��om�rQ[��9 yz�'� @��g�p��~{�K��RE�� �y o�	9�U����B-��BW�n����vs���,MS�����>�u�˳C�]דv�)看z3vKN�o����s$t��n�<�k�����g vK�5�R�Pn	���w��]���A���#A�X��ﺁP��PaY}�'�~����ib���`Mh���;%|�q&��pҀ�k�!*�HE��!m5�١[�Bc:U;BM��� 	=�nGd�-�=>��̤o�E����:�:�x���l�k��+��n�|���0��#A���Ͽ��.Lx�e\�������P0�Q���8���������L�ڢ,�������_��?����������?a��_J��z4�z���,���������4Mr��4�7���8>c��d̥� ;?u�������)�r���{�U��65]/G���G#^<IzN.��,h]#�
^�͡�M�P�M� �Z�Q�z�v�c#"�5!��h��&}�F=>�h���Xp�9=<t4�ƹ�x'r�Ӳv}�X�`������#���O)�|��F<T�,�2�������/���������P���u�u�?������WJ�����A;�&(��4�����+o�_����}�[?�7#�q�5��9�0Q"�b�n��/*���x�6�-�������c���~_[��?�~������w�ys��}`Փ``��ɴ�Q�;2�$���%���2Z]����#&���j˝�QDi��8i.���(�6i����0W��%�4�l#�^����~���Pz�8���9��Cv��*W��tm����;Tl�Z�w�麇����d[T��T�FD9�z�4 Y��1�\l�#)T`n�v>��*�I�t�ֻ�Y�J�ԕ�\㘃�LFZg��Y$9�8��!_���P�wQ{p�oE(G����u��_[�Ձ�q���׊P.�� x�P�����7M@�_)��o����o����?����8�����k�:�?���C����%� uA-����	���_����_������`��W>��Ȯ?���	x�2��G���RP��Q���'���@Y��x�nU���z���B������r�����/5���������?�����(���(e����?���P
 �� ��_=��S������_��(	5��R!�������O�� ����?��T�:����H�(�� ��� ����W���p�
��������W�z�?�C��Z���H�(�� ��� ������?���,
a��*@����_-�����W����KA����KG����0���0���.�
�������+5�����] ����k�:�?�� �?��:�?�]Ġ���Q�a	���\0�I��9'�I���E}�D}c��0�u9�$)��g��_ԁ�	���"����ѥ��*Oo��s�8��@�6��Wo�0BU�^OP���E+�F�>?BMl��q���P56�a1�u�燻���>L5{U�\�i#r-�I�B���1��T+({���Q(.�;IVp�盒}8�����@��&~/��T�/x�P��?�V�������������C-��*C�����q)�~1� ���P�U�_Y�|B�N�}��[���"�Fo���`Vۗ�����O��R�Y�jo�X/�d�a��B�E�A2����U����ZʶiO�����4=���`�I�>��� G	U9H��r��)����������-	5������w|m�����U����/����/�@�U��������#�����-����k�B7�X��sbd�#+�F��V���߳��J;Ip�����Dޓ�G�={�J-�ِ�+nK�fg�z!��Hd&y�q�t��?4�#��cf�X������|Q���t��B:%rط\=��I��k�q��J_3��.�x��7얐k�彰B�%\�w��א7����w�a8��q$H��]7�u��,�O����t�V��e��dCT:�ɳ���-�8�M&�3e�6�#d}Ꝝ�y8p�vo�|$(�Ɍ�6\�Ml��}c��x��	�[b՜oR����}w~����,ؽ���?��E����3�������?��/u��0�A�'������?%���WmQ���q�'Q��/u�����$�(���s=!ӣ~(���1��y���(N��W���tK���{����F��D�A�8�7[��vׁ�=�W��$޼����fi���7��n����Z;������q������K�7߿�.]Mo���j]^��kj	��ؒ��[B�8����u�!�ԙ�a�#_�FF��@F���2����*�Ō��q����rѰR̍yΜ�MJ��0��m;-�D\��c���b�`l>���s��}���7wzk�Ɨ˚�T�~�K��f�!O�l]2:MM|zO̤ЈQ`������n���a�ɍ�{lv���/퐕Kj���^d>�E/2Y�.ex�F�Fcޱ�Ʉ;��!c�
��l�J(Dv�r�4E���5�>�u�D�g�q�1g���/����������KB9���(ԣ1���9�����	s/����QGqz>����.�x�O�h�q��>6����B����������R�+��%:��gP�{(";��t����tO=���_8B�2�/W��V��ȕ�Z�����?�W���
#��+u�C��?��JA	�p�j�2����}?�G��+o��������?e��V	a|�ef8�gs���s�r�??o���9���]6�c���۸�3����C���M4��y���w�����~�͎!X��h��6�t����r|Tg���kT�F�FN�.|��^�gi;ߟ�������[�0R���j�!��n����s=�XG�#ޞ���0{��ly%<��i�Lc^��
^E�~|4	Ϋ���a��^�Gj�\M��%D)�id땝��z���׏S43�9�\�`A�A�9nzce�%����fswV������n��������o)(��O��O�ͲJ�Y�v�|������(sY�E/�_t���(��1���r���2�����������W���N�X��(�sXȉ��A�6N�0ۡR��e�8Ѣ߉^����-WՂ|T����^|�������!P���@��E���?�_(���^w��Z���j�����P2�?�@@;�6(����������)x��#^��o�?�nSQ쵡z=�������?��<������{}�c��G�s�����( �D9�,�Ф�Y_�g]Z��8�<�<?&}{,-�ޭs�|�uu�\!OGW.���O�������޹?��m{�w�
nN�Թ���!=ur� ����֭@@| �:5����;�DgҙI���>UI�"l���{��w]�u%���uNj�G�3�u����;z*��]k4�t]�o���j�t��9>�V{f4�{�Y�b9m�U:�[r�劘��?ݶZ�jx���)4����c�������q��Y�R7V<�oMֳ�F�k���^[�?^l��4���Vْ�6/Ju�����Bhj��1)uLy62��x5������*&-%�h�Y�Z?�z��ʀ)�u�ZIuG��e��8���j��I�.����\��O������7��dB�����W���m�/��?�#K��@�����2��/B�w&@�'�B�'���?�o��?��@.�����<�?���#c��Bp9#��E��D�a�?�����oP�꿃����y�/�W	�Y|����3$��ِ��/�C�ό�F�/���G�	�������J�/��f*�O�Q_; ���^�i�"�����u!����\��+�P��Y������J����CB��l��P��?�.����+㿐��	(�?H
A���m��B��� �##�����\������� ������0��_��ԅ@���m��B�a�9����\�������L��P��?@����W�?��O&���Bǆ�Ā���_.���R��2!����ȅ���Ȁ�������%����"P�+�F^`�����o��˃����Ȉ\���e�z����Qfh���V�6���V�Ě&_2)�����Z��eL�L�E��؏�[ݺ?=y��"w��C�6���;=e��Ex�:}���`W��ؔ��V�7�r�,IO��j]��XK��]��N�;u�dE?�)�Z�ƶ�͗�
�dG{�ݔ=!��4]�ݢ�:肸�Bbfk�6C�VXK2�*C�	���b���q�cתG��<s�����]����h�+���g��P7x��C��?с����0��������<�?������?�>qQ�����?��5�I˻Z�C���Hb1�(�e��q˶�Ӷ���rgO���_�:Z���`�э����fCM�"vX"�h�.�j��oՋ�mXù��5vy���|�TǮ6�Wr`R��
=	��ג���㿈@��ڽ����"�_�������/����/����؀Ʌ��r�_���f��G�����k��(����i=�0r�������M����+bM�ɔ��į�@q��`�r�M Alz�q�%I�ݟE�ݢ��ƚ>��uwR�K"}&V<.l����ة����$�M�Aj=z�\ks��u�]�6A��6�zE�6�l����ӯ��ya�h������d�]��]��OE�;���{Ex��$%N�� ;��YU+�c���{i�a/l>%��j�S(�tj9�����lԚ{�Lkl�,��fS�
��A����*aJ�t,�a�u�]��,�=btywุmȤ֮4����m������X��������v�`��������?�J�Y���,ȅ��W�x��,�L��^���}z@�A�Q�?M^��,ς�gR�O��P7�����\��+�?0��	����"�����G��̕���̈́<�?T�̞���{�?����=P��?B���%�ue��L@n��
�H�����\�?������?,���\���e�/������S���}��P�Ҿ=�#���*ߛps˸�����q�������ib��rW���a&�#M��^��;i������s��������nщ���x�ju~�I�Z�����be�Ì��yyC��Rѧ���!;3��08A���rf����i�������(M���h��s�/v%�Wӫ��#
��CK.H��G��m�>+�Z�[�e�:	�zޯ�L��3�uj�n6#���YMڒ��IV'��f5�������>v+E,D�\0k�0ۻce�2��4�}"8*�bu;���`�������n�[��۶�r��0���<���KȔ\��W�Q0��	P��A�/�����g`����ϋ��n����۶�r��,	������=` �Ʌ�������_����/�?�۱ר/"a�ri���As2����k����c�~�h�MomlF��4�����~��Pڇ�Zy�����E��T4��xOUg=��o*ڴEo�:_�!�)��+Q��>{�fq� h�v������Ʋ��#�s �4	��� `i��� �b!�	�=n��r���"�+�r�0e�U����taQ�{��'�zWRD6,oZr��#�rXa�)��A,�6u�+�ք�b}���n�&�ue����	���O���n����۶���E�J��"��G��2�Z��,N3�rI3�ER�-��9F�Xڢi�T6YʰH�'-�5L���r����1|���g&�m�O��φ��瀟�}�qK��t��'l$���Ҩ��'�^[�V5s���GoB��]0�@����OD��W�5&�X%^�vQ�Z��\�N%�.,OÎ9�z����,�T-+��>v�e7�����%�?��D��?]
u�8y����CG.����\��L�@�Mq��A���CǏ����n=^,kzGVEbNbb�h��r����֢�S�c'�n��?�/��p��}߯0���ˬ	)�c�c�:b'dq��uz@̏-��+>�jFmY7��zDg��q�Ckrp��ג���"������ y�oh� 0Br��_Ȁ�/����/������P�����<�,[�߲�Ʃ�gK������scw߱�@.��pK�!�y��)�G�, {^�e@ae�;m]墭�u���Պ�V���i��Z��Q�E%�S[Ec9+�ё���`���j�<�N���0�P��TiVhm��z)��ӗf��y�&��'>^�҈���օ8e�;��qS�:_ ��0`R��?a~�$��PWKUE҉ٶ�bN��w��1���(%g�)��Y�&��p�/�R��m��^ľ*(�T$�Օ��Ժ��eC�G��]�KN���qmώ-k`y�b��#��`��a�������Bo�gvw>�2=�8-�9����ő����>:�������Lb�}��4�������6]<�gZd�wO����/;����I��{A����H����#��w��_tHw���M\z�s�gSAN>&tB���E�.מ���?�_w�y���n��#J�u����LN�鏃�˃�?&w,��Z��ϛ�����y��>%Q�q�}��������q_��4����������q	]�7�zp"�sq�	�7�������F��^�O�Fs��=�~g��T��4���c䤯v��	=���?;W�$r��Ozd9�t<Z���39��	�����U�އw���s<��lx|����B������������;�����;����UrT��-�$��ݧ�;���|��H* �m��u�?��>���:y[�����|�n�^}�%�jy^?�f�6����	�<���Jvs\CK�Y��x�_�s]ǵ�u"o�������;�R���7�8P���p���k-H?��mt3��4���k����k��skrvg�=�O�y���L�M3 ���^:��~�7·���+���I�L�kaN��0#�X|n<�g�&��ɪ����)%-��"���Ɠڽ��N�����w�v��ȏ���I�	�0��څ_R�ûW5�2=�;��K����������>
                           ���8�b � 