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
� S�Y �=�r�Hv��d3A�IJ��&��;ckl� 	�����*Z"%^$Y���&�$!�hR��[�����7�y�w���^ċdI�̘�A"�O�έ�U���Pp��-���0�c��~[t? ��$�?��)D$!�H��1I���h�� �"b�����X64xd���Y��=��B����m�,���,dv5Y����6�L�6�d~0`m�O�C����� SGj����1�b�lږK� x�%l	���3V���fb��{��:(T2���b6��?z ��?Q�h���N����Ȇ*�!A�����)!H���X[��A�2e����
�0��ӁU�b"�V,T�*���j�bc����n���jB�@��;���'�ٴy�Rl2i�&�k:Z<��7mM�k��,��,��:�� ���@�U]1(,�`�*^k]qb���^����CM�F>��>C��S�*jP����v�2Ga6Ud�[���gԧ�:�z��(ۡ�G9�.`��#:����/;��|�X0
�e+��p��Ej��N>M���P9\��,[�㍿i�2~1�;=~i���sF��S7G6����5�GY�Qyl�)ua�H��Ou	3ߔb�y�v
eLĶ����5����3���f��ա�{�]��4�>�%��냇�}n+�����u��>�{�ɋǣ��?
��'Eb���Ę�D�'3���f�����{�k_�V�m����_1���H�(�r1.�ck���PM3B5h59;�� ��9PT�O�L�1�竤\��P98*�2o��l����A���O�:��� ����_#̐*�t9?����������0C�;Pi�
�[ظ�6���4��O�)�������n:��uf`ȱ1^
��[:}4��2A��Y�ƀά�ـ:6�^��tܡ�b���l�qL�3���Zڴk�� Vd"�\����O���f{�� �lhɓ�S�����3Jc�
����)�c7�9}��j���5k[&R�D��wE�ȎT���������Xi)M����:���{o�;� �aEc�W~�ٷF�Ps4]@Sij]��7���ˁ���!Z@�{4Z���� ����H0�'��@�Rs�A�?�s����$���Av5�k���`��O��4{;tWp��&O'�Xi��W���P/����	m��t@C&j�."���ahFc�R���J��;�7�+�;w�>W��79��Ro�P$�w;����W��ATR��{�=J�f����}�G"���X?e����Ó�����s[/�A��I�f0� P���,f�	���ޒY Z��	�\6g��N{�?L����uX�=�K K�1�+�cc���s�����,�Nydh7y��`o�����ل�ͯ���>�9��v�>�X�:�G.Bȕ�f�h�UL>��&�(�;�Dv�CA�H�A��)M��g~<�~�v�3��6و�f��7�<m���<B}h]6��۟�����F�6����G��l2qz@�D����q�eѝ�W�+��<t��^9��©�@k����O���~(���'�k��
X��|�0C�GkyOm,�Q
ǧ�_\���\?)=:�q�3�l���OO�v��;fb�稷�3a�u�Ӥ�� �6�\:_��u�Uw��T9X����&�U��=Ϯ���=�C<�]b�r��x�Y9YΧ>gʕ�A���`�6{N��,��_'�rڴ7l��_��50Yaǋ*�n��4	E�x�t��,ݩ\�o�*����B��:��h��.F�s��R��kC���#F�1P��D;���V$޿xʢ�H�o߂�3��3xj"��=�$̹���mP$�8�Ӯ!�?~~��R ҺtN�tzB'�i%LF�o��<����i� (�$�_�����s��p'�E���������X�_6���AӾ��2���´�����
���|����贁f��utLT�.�Ў�~=˾�:w��?�/ݽ�e������}��X��l�s'.����7���_	�t�����G�G��?����J`��o��±A��ed��|	:�f���v���<����#���ba'��c"N.�vw~v���^|J��c"B��tl���Ѿ�`�'V߲Q� #�{֐�D�Y��ҿޫ��X�O��˱�gҙ!�.�����Աu$e#����<~�̿UG\!�	���ŞBݘ	�0��.R����ke�0�:x�3��{g�wJ����i0p(:�����-�M��]����4}��P�o����A�|�Zs�Z���BDl�pu)d�3�R��W��a8�=�q<����@@
Aq�o�� �{�
���[�����&�,^����]���T�M�8Y��J�����d��m�ѴA����~�Ox=4���v�n*�wy)�4�76-�R<���]	�U���?w�����B��)���l H3���瀌��e ��-�]�̣�)�
�"��V�a���� �����i}�P!����,��6z�.zqSwiƳ��LQr�^���l?�Ė�&�AxIC���):&�H�K0��gi&/�ČS��ffΘh}:YƬ��raLu*��ӫ݃Bf�0����)�r����#��s���%3��Ґ�@Z�"��H�?+�wc���1��G�������>��۟���>�_�z�GJ�UOA�bYt�������hTZ������������o��������_��0e~�	Ej�"I��V]QJ�z�.)[�D�^K��p"IDRLJ�I�R"�H���V4\ۊF7��k�/_sӄ7���N�tt��/���6�������G�>�6,lښ�����6�lT��}��&���W�|5�����Y�;k�_6����mp���H��~"8sb�ͫim�a�1A�[�`��h���W0�������w����<�[�q{���5���率�IK����K1!�����+o�5�@�n54���;�aRz��%�d��A7�O�^Om:Y�o_�֠�ly���E%k��juA�oE���V����$�p��m�PP"��@q+51aJR4N��|jW���Z�S+@������E�ʔ��l>%W3���Q��S��TJVR��Oʍ|Y.:�q�E_%s}�&��LK/�R���>�_���S.3�������Q&�,����K��l�	�j�Ul�rz�y����E�\>r�)��1y�%s���uN���ix�"W�߸���%�g���M�Y{���*��ZX��M���)T3�b�ߞ���m*�BU����B5/T��Zv�ʄa�;��<Y+��^�t�>.�r�����L�@&��.�,��Y��u�v�sZ͜�%w���;�(�u���I��)��.3�BR`r�wR:)��$*��0
���rY[�]���b�VM���Lr���\� %�F&�Jy�{�]Y��ɜ��w�,���E�Z8���x�v�wr�ci2'���䮱�:9����)ܓ��P�hZ�?��uz�b%��
�a9v&e��Fo�ZM�d��魚�e��^���n#-�\�I�����e�����|��*���|�m�A'��'�������?v�D����R�XA���.w
2�GFV0%��9J�K)��+���L�c�z��-x���$BM��E<����qr�;NtSj��oT�{1�.��8�3���
��Syg�9.�BA매D������;��|���!�`0��������׌��1��l��AtsC��� �1!��?P&`��M��Ex˞�J���]uw�����c_Ê���?2��'"��u��J`�O:,珉q {�SV��+�s��&ˋlt2'� ��J�� �{���=��Z�{̝��BE|���]���4R.�{%#�4�˕���MY��b�S8j]fa*���Xj�t����9�u�/���hVGѣ��pNk��'��N� ��P�C�#���ޭ
����&.�s��>��=��e�������*��������G���e���?W���(��O���l����z�)����咒.5����L6}��ׅ����D��с���cdϲ�V)N��s�-'����#����.m�n�aOܷ�ޅ����j����θ���瞵�|���;6��%u����J���]���J�����' �;}��E�������L�,PF�/� ��FY���ݴ��,��!s���<��? ��7��lX<�4�k��"�p�FuAC�d�hC6h�/j	Xe^�Kc��?-s��)=��� E�#8� H�6Ԍm0_���mJ��t��V�����,��q�� QU�#����֕я��b�v!���g��xo��4��AXxؓ��߆����ȏ8w:<�����4Ȗ���M����$�X�ݫ���;h6���1���4���cz�\C혌�� �?^h���؃˥D�@��6z�J�K��ÆM/ B@ӄ}� -$��MY�v�؀QY��mi�K��a@L��z��dJ� x^F�l/6A�ɤ�~a��(/����J=8F'E�.o<?`*ꛬ/�@��lox4��?���<��"�z|��@릊d|�����^���Mޞ����_]�����Ƀ������F�5����v���M�f��c�I�KRs(��|	Ldu(�u��>k�i��կcLʴ��(z�dN̯;��'��8Ŏ�c���Z~SzL�R�Ȳ����٥4�_>�rJ��������^���h���<U�.�@�u"l�0j���=���/��R�c�"�r��M��ZU<)�v@��)v�������G{�,!x�*m�t�v�|E,󵡢�B�oz�a�����'�R�d��b����<��fpB��H��ٵCW҉�I�ێ��	!JE��H��q�	F����G�S�n&k�:l4LԠ���1�\Cq�D��UH�P���4�뼂u]�?�a=�T'tp�m����J7��m�F"C��!K�3��y�L����⃉ӑ�r�?}o�Jm+��B�Y���PU��}���bl�Gl�S�d���dmُ�,lc��_���%�q,-w�4������3�j���ʏ�Nr��ڎ�Ĺq�Γŕ;��qc'N�@�!�@K �7�݌`��,�° 6#�7���k�9~�y�wUn��i��{��>�����!ls�O�����<~%��~�g�?��.�ŷ'E���?W������o���~G>Ǒ���������譣C�����5t1�ʟ~�Bѐ�H��*�X�
G�r�)IaM<#íA*dT�	�lK�!��_H�x���~��|���~��W~������䏞��8�{�],�;X��G�^�h��_����� ���z/��� ����?"_J���=|�0�O��v�m��{��n��b�S.Z�����n4Z>6�t,��z�l2,}�t:��~/�/X��,�
�-��W!>tUC`Zv�P؍��Z3�XsA��ٝ�V&6�.iB���B�@
��d=[��
�3DH	���N���HkQ(
&g���1[��ǍAl�h]�X74|��L\�����ns����L(�̈́	3�rs�k�T��*n6��i��B�4���E�y�W/��3^����3l��׏��iz���y͠:� S<���S|id�|�k��t"�.T���~�.�쬄��3%Y,SVF�+e�B3Y��"��)�����$����5?]O"L�A��	3�v�I�ْC�Y!��B')�yD�:)��"}.��F�4��05+��"S����yx���*�4߉/&=T+��.q�@汨F.��L��w��.����43���dMk�IJ�UKe�H'�Qz6nRbnn�'��X9�����������^�Mw�^"w�^"wE^"w^"w�]"w�]"wE]"w]"w�\"w�\"wE\"� ��0�.�f)E���O�J�Õ�Rb��9��7��x1���8��60�.��q/jgE�s�*'�K螻�<R�[��۩����@���������A\�S붗yj:Ċ�Hz�3D渁gC�iT�r���f	~����ܔ	�jiZ=G0��S�DY
7��&��	N���Hj��j�����&�'����8c+s�ٲ�#t-��Itoi⭈�Sf�[87/T?:5�r82�1J�a�C�9�)�fbX�vb��(N��<]�D��eS}BᒹӊJ��ܤ�Gd��J�~�̢Ԁ��˼[�w��ہ_8z=�A�(���G�=z��r�?� ���u���n�}���o���&���G��Z>	�s������G�N>��^�:5]���/z�����x#�ׁ�����[�(������+�o<��c>��������<��+EYfi�2YZ�|ވ�r��2y���r�b��ۭ-�/�/Z�'X����8���-3a�3I��Pr!���Ky������\�-�
&�qD�ilJ����]	���o� �D����tZ�������x�BH5J����Ȕ�S�cv�W������T��ln���z�X`��z�mQt|�TZ�8i�F�֣��6H�;*?NWFx�Dj"���L�x����+�4k9M�S���4K��� #�@��P!iAf;��3R�[T�F;*]n'���HĐ��sK�l=Qu�4_�/�SdMQv�)�e8Z�՚���k�&.v˃A�D�	�k9˂�`d-�~�l!���9m�����]f�tÚrܘ3U���-^�J�d�G����ǿu%�ā����B=��|yP�����δ[\n�����e��]���4�K���� �u�#�q��"��"��Y���j#�o?c�gf��e\vGn��.�#����u�{����7�ڴ���
G�[�e:��Ɇ�Vyc֑�|&Oԓ�8�Vla8,)�zܯ���X�.}6�0Ōb4��í��y���è���F��J��lV��*\�ڴe�6��M��6���x��Gt�:��Sȇ�N"5�u���8R힟Z{:��A�|�W:�dZ�R�%��b��҂4=mբy%٨(�T�/��1�.Efi�	�ys �7.5/E�a:��&S�v?�Ry.B�[Åip�X�1#�x�E��³��y%OdE�H+E"dg��xXS#S�1�+��-��l��U$#3I;�d�p�G����4�2An{�*de_�L$k;�*�"0�]�����W+�Rz*�+����X��R�C��Vp�	���c.���*�5
%�Cp�cq�K+ճ(�<Ki���M��et:S��;�
q5��)g��y�)�����E}h:��*��=����	җ�BJܐ��Ba�nF-E�N���|��r�J7D�V����l��5�T�Q���a2j��4�cSi�4���%��P6�-�F�U��r���.c&�.���_|˲���w��M7��ٍ�/Z���.�����<tlѢ���*8r3>�e�g�i�2ԧ��+����7��6�<F~���V��.��{����ϟ?�?|�<�����#ڎ���D� V�>E�΀oISeۇ�]�@\ӛĕ^)�y�y��t���:#��� ���#2�q>A~����)P��8�8uG�k��{�y䁳8�,O]W� x�|�`���ҡG��"�2+G�k��t�t�� Od̯����������H/���G/8���A����ד ���
�;��ts�����T�
�/�Vf��z�;�0V%���4���Ŏܸ��;
���4���3"�_���926ifw��]���H���I�S�k�*��9?�t�l�㧫���3�z�폭�U^Ѣת����U�ɎN��h���s�cj|oo==VG_Q�lH��z?<�HPP� !=����%-�8F�G10E�6��'
,Բ� z& 1�"v*�2H}c�]\ �3�w�ؤaв�S�� �fq.���Ի��&������ �˩O��/O��jNW@���+��V��&>$�MO��`������z�_ g�ADVТ3��1���X뭭u�v �w�W���h~�ʬ��A�|��,] R�̢�'���g�*�L�*�?Yu�b[�h���%���q��{��юW�]�Ip��:�z�"�gm�}��e�tb���2z��$��6�O�aKK�I�8�j8���jQ;�+��@��z!�g䊉+�������ԃ��?�0Ӱ�M���	�����* �.6��u��~�_�/�LF�}=w�_�1t[=:�� ��`S!z,-{�Q�k28� ނ��>�)OB�P��Zm6����6o(�� )�O◧q���粫k@W�g/"��B�m��p~в���dM`e�%�s%k�hٺ2�^���-%O�{��Q�� 8\�a�n]\*��/ ���P�$U�/cX%m �cp.�bz��v_�a�Nv �ݶ��^q�Eo���#�c��� �	����ӔT�=rQ�@�J�&(�񟅜	}�vp��,�]� _�.� Q�6����*�u�ii�~��@����`WV�ce2����C�&͝�\2�o�nZ�<�t;h�Y�$�s�>�n�	r�#��[�E ���D�4kX򪋫�=]�8�	�e��X4(0����.�lto�x����c��� �ކ�8m1���j�i"�-B���W�Z%kݶ�����jBH��:3r
����23��z�:��:�k�'ش_@���1���^�U�͉�	�C��	�z?붉�ֆ�Ɖ�S�9�a1b%)��������_��$�-4egCi�@'(�w���w\qpl��b��Iߑ���j�����
$��܏:�����������������m�����+���b3�'�`��}$��!>!>A@j˶Jv�ܰe%�vr��h �oó�g���"?��g 2�3T1Z�����Q��+\����*vt��R��Y��\��ծu��'���ӱrEC�\�f�H!K�I5	Ij���HdH	�m�j�ZJ�#m\��f��?F��v���p8�H%��}[�����DX�ì�gN,�*�����l�Ƕx�O�'O�Pa̐k�bǂxf��W7��IM����&�bY�qB	�0)&IE�cJ�RQ%$5eBB
Y3�)ሂK��X|Ҵ�����c3�D���̲��o���7�;�$�亣q��	Ovfߓ�E�V�]����wd��cw���msE�+ZT��\�Μer�W�2�d�9�\��/�\�f�"W*=àu�]��[�K'�r�3x�E�����_pa�A��P���3���U�A���.��{��U@@�[;�3�Π���vF�\�'-���i���Z�3��b��-��o�A�6io��;]k�nxl熉Bw�!���V7g�j}��nz��0�b�ߊ�y!��sEy��&��W� t�>���l<Ǯr�<�rL9���"�qY6����P���(
�Y�3i�N�CǶz������Yy��?��m�&<Z�����ZES���e|�,ˉ�\�T�F��e�3����F�X�>���d=�k��bj�g@�=fY-�&��%�9�'K�4C��gq�e.�ϕ�)�q����N�1��E�/�A=�-�O�8��L>kK��\����"�xc0��EL���:Mݝﯡ���,���vs��:߲]��d�X��`��2V��~��0���{�F.u���N���ͮ��;V�ߊw�#�9+3V���@!t����3��m����zq`�&�f�_�$9��G���o��6n��!�|'뿏���KF�f�CD?��>�+���ķ�c���H/��MoI�	zH{H�X�[�*t��{I���'plS����A��#�K�ß��i�ʦ}��K������_ �����hhh^���f��W��#w��:�{I���9&Y����E�v$*����l�Ȗ"K�X$��*�EۡV�����pTib���	�u��,��j�Wa���m���k/�g�m�ɼq�O�}\S��:iet�:G�+b�M	�;�4��u%?��8ɍ��$P=��E��"m.U���rH!2��@��E��-�=�ޖ�����y�?����ޤS)N�Z*^	a1eV��a�;F5��؟�����O���?���_z���Ɔ��8iw����������H���'�������Gڗ�� x���ʧ��?�����[�d$r���H�,�R����+��� ��]��������
�x ��D�O����.�Ij[�S����j��G�Jti_��2�g����?�?���KMl��+λc��/g������^� D�(*ʯ��*&���J*)؝��T1��(:�k������:�N8��_=��C@B�O�?a�� ��B��� �������a���" ���ZP���q�����J�V�o���h�y�S��ϻ�ú+t"&_�����Yֲ�Rz��tn��؏�~�Ì�������'���Ϣh��̪`��}{���Ole�;�~��Z�w/�f��-��f�z̡pv�,׉�`.4W���::��~�;�U�-�V�<�Į8E���^��Y�o�}��>����l�����ոCԣ#����L�Hi�di��қnW�E���v�S��͵�<HS_��v�5S6����qF��,T���;Ʋ֞�C�a���vC����S�N�|X�u-���?���f ����_�/�`���o���C��6����U5�����?�p�w%��'���'������H�U ��'1�����o�����7����@���������o��;��?�R�;g�9Ӄ8gI]��ɀuS���������?���7]���z���`�q3��N��h<�k#�k7�h6F�L�w��e5/��7
��IZ\r)(�v��s�?��A��v{;dM�P��k]��X�����N�l�b����KI�
-�����}�om���8�����	�)IL��9-�+��FJm���1���IIf���m���)�8^�&-I#�z�dO5���3M�/#�#c�1��a��$��D���� �o]�C�����P�������z/��A������y@p�!f!�3�g�gpF����0�Ðb)��B�
B�
ِ�*�#��~���������?3�?/{��<'R:h��&��iΟ��p�6�РNEg�2&�8h˟��-����=\�uq1����EΎ�������W���:��t��Rr��9%�c5Q�7��(�Y3f����5ց��o
����5��k���
��P��$��j���{����u��!P�����Ϭ����:G]m��㘋m��笘	�����p���e��Q����ڣؾ:��A3�|�]!3�m�*�l^�I(�g��W1>�s�<��;��u!u�ǆc�7[��`l�"��M'����h��I�k����#������(���W}��/����/����_��h�:�����G�����[��+��/f���b�ЖE?:n&\�j������e-���8���������ŏ���<�g `ֳO� �Jհ=Z�K�R�n� �y�h��)=tu���RJ/�-��W�~����w���.m[��2$�9�8}"��ǘ]?P����z��K�<l7��,��'�nz
�����+�� �ܖTҵ�K�ڒ����p`@���N3���>�$%����FR��b���I����I�zn����e-�!���ڛh��KMʘ4y��ǓB�P-YSG:��Y��ώ�2�өޑ�d:W��K��n7��|����fd�}�"S��>lR�C�;c��Y2����r��n.��h���#�'���W>���0�.���o������c`��
���$���������L?dQ�g����/�����������z����	��?B��� �i�f�� #:�}��}�����y��(?��N��)���BDs�~����g�8�*�Ϝ����qUj��L7�!1&	��H�ϊY�s7�K�4��b�O��P	&Y�.�]�K#�jm?�:��Q�톒�Y�)��>N���_F,.��Z��9;<v�%��x/��r�}�ڴ`��[���������O%�x��E<��,�*��;��"���H�?�����_E�����&��w��_7�_�:��Մ��_�}��FU����S,�U����[�7������vd6.��Ծ�.I���z���Z�ѿ�����~d����#�߷V6����E1��Ã?f��j��ޜ�ny�,YD{u�c��N�9I��x�Xe���NW�l{��[����E����$a�㼬Px��ܘ��G��v\�KǑz�H��[/Wy�z�]�N�|�8���{���4I���ު�7�lcG����{\n�FBv����ǩ�X4TW�,��u��d5��4�y����\l��hLdo�n1N�k���l�1��Y�J��W�����MFFg���E��43ݡ��Xve@A�]���[��p�;������(�?IP��Z��G(��O�Y
��*���7���7��A�}��;�s� ������C����_*���/�@H��O�)��* ��������[o����7��
|�����~h���U\����4��� �'q�������@U��|�nu���~����B���5���v�'������?�C�������yr��T���!�FU����4�?T�����W�p���ă����!5���[�!������E@��a-��P�?��!��@��?@��?@��_M��!j�����C����_����H��O�h���� ��� ����O��?V�_��0�_����������+���� )����ʁB������a�����%�	�G<��*���[E����#(�k �����C�����p�Cu@��	�*<��`��O����yH|(�$]I��g>R4���B@p�/�4�p��?�����X�����0�F�
�?�:����ε�����x�߼ˊq\+z=IO���������Id����i�R���֖<.��)��p�s�5���ʖ/s�rDo�u���G+�b��ZG�;��$�㭛�G�OF��M�=^zJ���M$�Ԑ��vO��1�p�����P������o�@���_}@��a��6 ������kX�������>���oRsn�N�jl�;4z�H�,�rؾ��18.b�n�O�����^�e��7r�_h�d}T��d�c�1�8:疶k�ӣ��r1��mq7�ʠO�Y3*pJ׎�n�,TƄ��[������w�+����#������(���W}��/����/����_��h�:����~؟����>o��K�_�����鈒����+_�x)��_\����^��M�)�'ym"V�u �-T�s���	��v,mw�Y���fJ�'Z'��C[?�^<f�aN��p�Kv)��A�ͩ�4/I/f3���}�7s��أ�ǟ^�[��˥�o���ے
C���R�����N\���@���N3���>�$%����FR��5���I����I�z��,��j�Z�;�NP�Ņ$��$�~���i�mν�7��G���<]L$m8�Q�V���F����И	"��Yg�4��Z5�ی�v��]���t?��_�������9����#���|������_P���I�'�W�����$�������?��8��W��ĉ��/�_����\O��@U��?�p_�4N2��U���?ӑeqv���a����m'	w4A��>e<t��@���-E���2�u�4-گ��r�Q�^�{�F�x������q���/��U��oq�ں�)�[�Ûuys.o�%؟cKƎ�Hq��iդ/��!I�m���n)����5rvmTl����F�j_e����1ɟ<��bR-NF�kQ��f��=�d׮��mj]��S���b�|1q��k����^�7zo箯����z�ZT�����^�ٹ>du����)��H�Ĺ������ۖ��|[Xq���XLc��P�c+�6:�W.slvDER�D"���%"�����3�E�'�<O�^�LD�v#�b)q��T��)~�7AaH��`���6z}q</v_Y��_���	��<��A��"T�����������M�
	��0͆��I�d��)a�S\��L�G�@�3���(�P�?��_���U��9����\�x��6H�u�c�7�OG�`�/�Q��F��ȅ'E����ʟ�
��rS+0���������}G��!h��� 
���G��_%����¨��������,�J���+o����������4��S�v6�?ߩ���֧�:�`^��������[}��~���Y�7xCr��_����m?��|?�JvǒJ��Ꭼ�vJ6�ZK�=>�3aC����N#��/�!+ʛ 
�]�-��|\N6�n�hYwt�����~w�{����ZnIlƉ���y�ฃ�Nw��/ʴe����MW��c�}?1�D��`�g�n6#w�	G�&�k��Lд���-BL��T#�3<��9�\H�hA���w���ڲK7C�X���E��_����G>�����JP����ِ#��	���$y�����+���y0>��>�_�&��O0�O���(0�>U\�������?迏����Zv����h1~�<p���N���8��|�+E?TE���a'�����l��콲��o�G�o����8
��
����j�Q����@����'<"	�������C���� dP��c���9��J�V�G��?����ݦ���8�z*����q1|��~z��kH�=�������R��}T6����}nI�DqT�P�s�^Leu1���1��1��c�h���+콭�{�
{9�r)�{���&�����+�9�S疧��<��ɭT���[�r �(�������Ig&�f��T%m7����^k�֞>�^�:����zו_W�{Y��O�y:�Z'��ں�С�r8صF�J�u�f�(��Nw��SmUa0��`F�����)�Ӷ]�#�%GZ��YK���m�լ�WJx�BS���?V��?JMA��y��(uc�����d=��a�V?����+��ŶaKJӰ1Zn��-�j�TW?9`��,���k�Rǔg#S��W��ܯ�}~�bb�R⍶�5��C�7����\���Tw�*/X�{��j���V*I��@�^I=����4y���k�C�O&d��8�y��۶�����:������/�?�"�g�B�'�B�'�����V��c8���o��˃���?:2�(�3r��_�K���3�A�7���ߠ�;�o���W�B}��o������?C��������;��̈l��"�z�� ���^������o&���t\����������.�?`���@��P=������������9���������?0$���� ��������2������������_.��xQ��?2"�!�ȅ�Q�!����	P��?@��� ��`�em�A]����_.���������ȅ�Q�!������ ����@;�����dJ�/tl�G���m��B��+� �+�����\�����������]ra���� ���2�a�&��� �����<�����a���ȅ�MQ&���9�e�湹n�i�1,mnK�i�%�2ΰ,��%[X�$�$_�H���խ�ӓ�/r��?��g����SF�[�7��g�_�vUh�MY<n�~�)'�˒��:��E���tl�۵9�1�S�HV��@�bA��il�o�|Y�Ў��Gv�'�Mi����Aӵ�-�>��a�.��a)$f�vh3�h��$s�2��z�*�׬�w;v�q�+�3�8q��/�%�:*����"+��|��..
u��<��P����h��y �?��ȃ�C�:P����7u+�.y�����#�?Q������:����$�B\6�`�l{=mK�.�-w�����5��U{�jV����m6�d�a)b�%����b�����V�hۆ5���Xc��H^ͷKu�jsz%6� �کГ��{-����0���������ب!r��_Ȁ�/����/�����������\�,wa�%?��ˀo��{��ڟ��vˎ��ڞֳ
#G��}��������O�"�ęL��J��g_�a/G�RĦ�wY�d��Yt�-�}o��y[w'�$҇qab��Ik��
�_NL2�:�t�֣�͵6��ZW�UJa�t�jc�W�mS`���9�?�*k�W揶\X=Mv �՚�5*�i
�T��z��W�G[ppN"P�����U�"8�+m��&���S��&8U�N���\���F���ʴƶ���<l6��?��aZ����J�BƁ�\�u��Ґ!�#F�w��ۆLj��Az����{I�?���O�x���i��)Y|�ߚ�#���E��Ȃ\�?%���ς�������'����������,� ��4	u�8�����������?��\�_,��-n�����\�����Lȓ�C���J����cj�A������#��]ra�QW������� ���o��˅����ȍ���Hȅ��]��R���	���8�����%*�ۃ�;��ت�	7����m�m��׺O�1����&V`,�w����~�gr?�������8|��m?��>o`������_�'�V�w�ĩ���1k�.V�:�xߘ�7T��!}Z/8�3s���n�/��a�a��&��j;���Ҵ_���>��bW�~5�z�8�@؎0��4*�|���VP�ñ2����XP��������
��<�:Y���f3�ȁ9�դ-I[�du�nV����Q�z{�a�bQ�Bt��6���0V�*CJs�'���/V�3`��������{�8궸E���m�/����ȓ�?��Q�LɅ������ ��������_h�������8ꦸI���m�/�ϒ���ȑ�_� ޚ\�����o���J������{��"�+�Fj�4'ßj��f����8����������ft|NS�� ��O9 �}����ǀ��^4JJE3��Tu������M[�f��ž���U9�Ӱ�hG�6j�z���[�o,�
�0�~; K� �L �&�^@/➠��ƺ�(W}�K)¾-�S�\�o�QH���w[{��w%Ed��%��j=2)����Y�"iS縂nM�n+��O���ara�QW���_������8ꖸM���m�/�_���,��gA~��)3��y��4C+�4s^$u�bI�ct��-�&Ke����xҲX��y�,�xz�q÷�f��������l�����w��?Lg>�F2yP-�Z�z�p2�UkU3�Q����p�&4�����j�-�D;{�^c�U�o5����U�Tr���4쨑s�����N��Iղ�K�c�\v�	���Z���C�Ot ���E�P7������?t�B�!����i��D�7I��?t�H�����Ų�wdU$�$V!V�6^�-��z�j-�;%|1v�������ґ�[���
�xع̚�b�1f1?:��#vBG�^����rO��C�fԖu�qy�Gt�^�7�:�&����{-���/�X���?���� #$�_�������/����/����؀hȃ�ǲE���-�o������{X>7v����r��{������r ~����r �� ^� Vv���U.�jZ� 9�_P�8l��띦�E��[Tb>��Q4��9�?	�M���C��j�U�N�f�ֶ-����:}i�a��'jB\�>�y��*�x*��a]��1�P�Ú7����k	&%������J�u�TU$�8�m�+F�D�XyW�S�o�Rr�2Hn��l����Ґ�*�Oۖ��E�"ME�^]i^O��-_6$~$�܅��Tz(���ز�+v{���1kV�Q�ܞ鬒�.�F}fw��)ӣ��2��3�[�^y��Y������o�?�$���O3���p��m�œf�E&~�Թ�����?j�DQ�DxM{��Q��; ��}g\���E��pw~�Y��ĥ�;�}6��cB'��]��"q�+����ug������?���\�\?J
�����88�<�q�cr��ϯ�
����/�|@ߘ�>��S��܇����o��Q�U�M�i�<�o������еp�aë'�=�� �p3����8n�k�u��l4w�c��w�>yOŌL#ٜ<FN�j��Г���s�M"'���G�Mǣ��� 0��͝ ���XE�}x���1��Ɇ�7�{��(����aO��/����������~<O^%G���Kr�_�}zڱ�ǿO��牊�pކ�Y��_�sܬ����8��������ZҮ����oksn�~~������d7�5���un����;�u\_'�|���;a�3�/�?z���Ym��ւ����F7���Lc������X�6M�7�&gw���$��kN��4p�4��l꥓�����q�|�;�2�/�d�D��洹	32����#�{�k"����9�o�R��/.�����Kn<�ݫ~�T����~Gj�j����]�D���S�<�]��'�;�{U�,�ӽӿ���n0��������                           �K�g9�j � 