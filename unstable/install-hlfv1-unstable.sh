ME=`basename "$0"`
if [ "${ME}" = "install-hlfv1-unstable.sh" ]; then
  echo "Please re-run as >   cat install-hlfv1-unstable.sh | bash"
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
WORKDIR="$(pwd)/composer-data-unstable"
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
docker pull hyperledger/composer-playground:unstable
docker tag hyperledger/composer-playground:unstable hyperledger/composer-playground:latest


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
� duY �=�r۸����sfy*{N���aj0Lj�LFI��匧��(Y�.�n����P$ѢH/�����W��>������V� %S[�/Jf����4���h4@�P��
)F�4l25yضWo��=��� � ���h�c�1p�?a�lT�X&�Ɵ0l,�0O �@��
��� OK���x���Ї���.��)ʆV_U��KQ �<a����_�#�:��t�wǹ$S��m�����`���(?�R�4,��� �w�f�o��A��Z�ރ�3BJ�
���T>K���\v��g �q� �	[��9)Cס�NZFK� ��֒���?K(Ө6��	%�sP�k�i�K5qq�z�@�}6�̖s�_s�����a]�*�a�H����G��W,�D#�ʚ=���A i��5�&�s��wSy`f$H	��01m�Tv#�|^�=S����8#0�Lѫ��3�(M�}ԵQ�n�6si�Y��l�r8���s����㘈~E��i����|0��tw�f�1�J�l�_]h;�r>0ظf.���Cj�}���]bΨ�r�&%.��+��!�Nl�T"F�R�V�ҳS+�0�s@�Lu�K�����D+�J��=��.k#M4���|\�S����7�&쇰�G�y�6�"�7��F�?���N`y�N�����9��@�j�[��v�m��n�������/���繍��x�]��ꑆlw(�p-���4ɟ�ja��~L����J�VNI�W4xI��栉~E�4CF�=b�ߴ6��`��c����I埋m����/�ȿ)+]���ۆ� m����Eځ�,�T@4��?|t����Fk��e�Ţ}'Fa�LX�R�}P3�*$����:`�σ	ǀ�7���m��P3L��A��� ӵ�&�'��Ծ�`˅$Iv��aM9U<lMU�n����;0�y]8D���n�Nj��U:2�5z�I�bh.�����PG�VE;�Ȯ��������5C��t�>��ۮf�P��&��(�������g�^���FÉ�h;ORC�K��b��؋�e���sS9�2�D�xc������R����ii�u�&�����?���X�A�Z���_�?��Vh�:q��#;��jQ��}�!�\]W���G���|��HQ����M�B��A�ח���5y�"�=@���k\��T:�P{�n5;����� �6����]v^�NR3�RQ��d�r�u���˸���i��R!�p�Wx3�4��F���@�� �*�#桐1;�&���ar��`S ث ��a�iO�}Ƙ���s$2�Vu�#)�7���keALq��kC2 ���ѹ9蓘�L.��Xas�{��(���UR��4�ϡ�A��P���}�Aن��T0�JĲ?��~�{/s��lH��A�s7F�����:Pu<m~�~A�׈�n�9�;��xI��5 ��ׯ��Z#zC�z� !����ӡ-+T���f��Ra�����|?V�� 3�߬�뀍��ˆ9�=����gy.>-����������ų�<�q� KO�6��9fMak7k��Hs-׀��~kH�s�;������UR��au�oH7A�C�ͷ����`��� ��6&�ˡKd�f�d9�:�K�J�T|uqum6�F�Pm��6t~DF���p^¿��K`����CA͆7׉j�[���Y�X�S���R�ճj� �j՛��@�G;+�6D�մ_�ta��+x}�v������	%>�zN���߁w�����<� ����$ĸ���]PD��t�׀~��{M�R��xLttz@'�aEL���*�w�E�i�@(�$�_�"6G�+h����NΏ���j���Ǳ���[l�/���d�y��"���̴���_<��S��j�=��Pu4!�B!ӂ-���qT�@e�h�{����������qF�o�?����p�p�|�H�����N���������/���0��ᢂ�������Jxn�hn���eX?�Ru�� ���z�Sx����?�;;�P����/{��ٯ��7�s����QC����yFj�X�Lf�Ӎ�c��*e0A��d���Vm��hP�Q��K,�^����az��1٣�5�>�F��(�BV�=x�k��#��X䇹�O� ���_^���P��Y��n�?�����G����m�Ȟ�j2	@����^��H� �{���z�b/vbg1>Ą�03*��Z����w��,/�w�,�p��E�䟋o���*���n�j̣W�*����%1]�½��m,��ga��/D7�?��=�#�I�>t\s�ʇ�#V�KX^���YpQ�Gt��Xv#�k��V��y���8���u�#*�^� d�H����' �2��UɿF!��(��N���	��!vG5+�U;��ph�"k�v�w��+Bn�
"�z컍[p�#ܩ+d��/��[���4cx,�NU�N�E���"U�]�dQ&E]QhLGA���e�G#��6h@���s�MG�ȷ"]�_P��C�*��is{�6�,��?����_�
��+���9�x��p�GM���XSu��]�w��`���[�pтTHJ�J��:K�g"�O*�ɼ����<��&s;YX3�#�!wMmRX�)�)N�)Q�!���RY:;���N��JE�UKi�*���� Z��z�>,��=WW/���e+b��/Ga�	ɗ��\1{���R~/-%kٙ�s�=4"3ɇ�3	�!&l/0�xR�bWW��W���H�Z9W=���ʥ|���Φ�4���Y��{���٫��]�QEؚ�w�>�jc�; ��m[���k�Y�Fz��,����q=�hw^���U�wZ���c����m���>{��=��*H�p����ZBM
�S��|���mf��V�05�`��;�+`l`�Ā�Ƈ.�Q?�) ���Ţw+��^�W~�����?{�(�%�?���w����&���a���ϥp��?�M�4*����\���5��4䇇��(�]V��|KH��:��xup �lI7�-{���o�\U�`#v� �<�?u� n���W>5'n�S����>�.����X�\������k��W�?N`���kX|֢�����J%���Wk�p�N�1Y�N����R�E�?��儍�������ArKUOmw��G�G-m��|	F���}/�o�'�|�۬�k�����\��l�ǚK�V��!@ ����o�7�\��s�����=x���\)x��1�g���{0�g����k.��+ӯ�L�;��A>�r���|De�m��Ϧ̍���F�T(E��`W�Z������	<�C�1�x������p��,���4��X����Ya��_�<��J�SOa�bQ��~�������� �?_Sgԇo���������#����_`��(<�%vZ
��|Bn5Z���H�Z��sq�,�c|�����'�D�m�w��#[����_Q�o������h����d�l=���Gy�z��s�J�mX�����u�_���"v�����u9YM���&*����@����������5��_�Fy<�T1�֟����'�2�7L�����#�S��Ͱ��w�6V��Qf���w���s|˴�@�s�����_|��X��[����;�2��8��GZn���*{�(�(_�����ÙN�w?Ҷ��޸��8C�²�,7�5Z�߉2;��l)|cGI�\FY!�Ӕ��"�;q9�`㲜�y�!�	u\�GZ�Hն������"HI�j.�K�U�����\*{�J�J�-rI��+�E��׋���H2;4��UC�jG�T�$w`��.�	��K)�j�Y��I�N!U�.�K��l먪j�[�4�Z�}����E�\�yyJ5]Gyj2�^Wz���.O���lU|�aU)��^J���N��6i�V���\�E��)T%��y��{s1��X�*��y�+TsL���q�9IcFi����d�pdRG'���QV���.�j�]*Y88�2�||�Wz�yR���#����{��eܜt:<9����ƥ�*$�!�G�eG>D4z�"h0�q�셖���j��d��M�V
|BlK�T��=��E&'&����E��v/*�B����ŷ�������h���7�}=�=�ǵr�u"��YQU�?�����N��م�a9v�K�l{pp^�&��Gs��m�R228�s��N�<���BRl�H�(R6�U378�Rb.ٳNe7��%�u���z��=$9�T��T&VP�7�>�r� 㞡L�L[,H�T�(��G��zJj�ڨ�@~G�LǉHG?}O�Xяk�z��jFڹvE8���a���)K�A!w+�������̨������ZY�{�����9b@_]]�#��/yCo�U���Z����Sֻjl0,cbO@��虀���ùoQ�o���Ww���N���X��/��G���DYV؜�\��r��p ��ԧT!��Gk�x���2�PGGm����䁡Fj�{J���:Sa��b�X��Z&�����ιdr�D�l�S�Q�X6��eFN�_]��^J3^5`�)�׻��QY

��>�U۩α^3�Z� '+b$]s���~��=�,t�B�)5^�f;��G���c��g�a���>���6>u�7���X��9�?�9�����d>�
.���@���x4v���#%}�%9>��L�&W3o
�m7b��M۔{ѧ�Qʜf
]	*n���[ϔ����仗���t�p��mup�$�M�]��i���\��)�ԣ���;���tX�R�᡼�5 �?�����&�k-��sh���\���e�a j(�4�!�f�z�c1�oCy�}���m��������C���T]�"�JVۦA�aK�U1e�pT�����!m����m|o��D�|�LR�|z�a+���<B�!P�{p7� i�'��.�W��n�HWL��Y�@�g<��5c@B���ѠA���G���2��"����������<���\<���YxD�c�o�}T�%�_s�tx�c���_�q�-��u:䥫�K�P��������D$�B82�����Z~}�B�Z��� ��q�Ɓ�|���ٻ�W���d�0tB����*4m�^&o���G��t��v{��l���0�v��=n�=����I�
�V�8qAB�	��8���!���=p����=��7���!�2Ϯ��Wտ��Qտ��F��?�D�
d���it(�tp�щA0"�d�B��eM4ń�9hViT���&���m��T�+ooHI>�+�S./��bK?��;��|N�`d��~Ѡ�d!ό�37W�� ��d��b��=���}��&���|��|�Y��Y���_�;���>\�ؕ���~�������3��?߻���XB�`���3�Oa{c����F�.�Eȭ�sr��c4�f��8���ж���3���A��L���t%8�0o4�r'��aFopM�*|u�L�jlG�̳�I�\���?��I������������h���|���D�D0j�\�.A<�/�D7�����my�)A�'kLG�Sʛvmc
��b%���N�@�Bl	�ǸГϝ��B�|$+s�1�"�K���/�S4��V���ɴk9���<�������(پn�Ge������1*��>5�A]��3X!%���\��D2G�U�(*����eIY�eC��� ��5�n|��u�Dd�i�k:�t��Љ��H7b�!��V"�[sz�~��0=s����ĩi����E�偸6C�m%A�����)��@�������16��"�ݍ�f}{������6$����^�S�X$���OF���z%bo�����o%~����/����:'������_��'6���'���R�oS�oRĂ�՝��}�����X�щl|'�&�E<�Kd䨤�{qYIĒ�x<.�b�^&���{1�J� ����}%�9	$����R7���'=y�j?Y���g�~f��������|������H��#���x{��5C�A��l݆~�0�{W8��=����7�ׯ���A����[X��#��!��2� c5�(U��ts�ҋ���0Ϛ6��G����g�j���g����"�<| Xu������*�+0�b;�M��i%gG��%��sᬖ�: �-����Fa�]�E��i�X��9]�9{̶[�qg�YHC�/��v���
�M��q�>*��ay܍�gB}`�l�ማ3���yixo�([�7��h�궝Wq����v#�=����A�6æs�_�P.��å��u�-�������}�ɎuSW,:W)�Z���@"��\�<kP��L�כI�1�垐��,jf=R�k�0CñW�C�Nc�X�G��y�ɡ���8��dn�4B�-�1F������<���ɩ���ME���N1a��xrV�O�E�=�����&L��C�u�W���YXo�YLp�`�LZO,��R39�W��)w���4U�|�D�6I0k5�V�Ώ��l,%���L���"rD�'���Fx�=A\�~�Zi����+���+���+���+���+�+�++쒸+꒸+�؆��B0�w�7:z�M$�?�VP,2;����f'"U�0gK*Y.w"z=;Z\4;������s�%��Kٞ��%
���M�l��LO�.�
d{�y'"ng~����{�jr:����46g���U�YZ���ݳ�>��F�U�dI��Q�Hk�DDk��x�	❺�˙�Ʉ�c� �D-y��!<��"�'�1��~���#��4��lyR��z�P��Ҧ�)�Oڱ~�ܾ�����,��PĔ�e�
5�'Ԅ]1�&k�F햚���ULS�A��OJ)z���� �p��ѱ�lv��I�Jȑz�^/;���C�
)�u�f�EV緾����C�B;���o켶�6:����i���g�nV�?8��0��ˢu>\V]�.B�����Fhǣ��(����l�.���}�oS(���f��k~.+��#�Z���G��~���
��7w��u���A�w�~�����ZUVZBU&������"�SeZ�2���$�^����˶�9�nx6?ݔ���s��	$�Xs��h<=�E��kj.�Q]5�S]�e[��D`��� ��P䢴DZdԮk,xfe8��$�ӬF��,�\!5Mf��}v\Urg5"���[�#93�ʕa��څ}m�v��~7Ig���5�yۚwⴙ'�\Q��q�ؠ�6q"�Gˤ���f�=�����͡�4KW�� #�H��B��Uk�e��-�C�U�n������T�y�j���m�F�E����>"��Z.�,����(�A�$/Qb�9SQ9I�'�A������A���	Q���#f��Q�>3R�q]���F�V�����7�����~�Z��"GY��Z����&LK%.]���__^���n���{���� ���� ��r߳��/UL�������3nQf��n�4�Ic�4���+y�N�V�=q'��F���A�/7�Z�����	'�K�e1�<�-Sk��Lz�T���8-w��h�Pʥ����՚c����8��K�ձ��N�����_�Gi-{6w�t��>/���b�Z�m�Q�G9+д}����ټA���\Hj���\a>S��t?���5��U�(�<��l�(\0�H�^��� �GݓtU�w��b�5��+6R�"��z�=��+��u
�ʊ�t������Rt�;Z�����A1BE�b��0��e����u�L�EdH+C"�g��xt����aJrĄ^�-��֐v�v�<���:q�-!occB�v�3&���Ҙ ��I��A!�k��J�8�՚�ݣ�x�L�*GTGzk�e&\>2sY��Y����(�����L�]'�D��z�i��1}���4"��O�E��A!<��Š����x�gj磥�n��Z�������w�	1 q� nh^ߠ0�~Ik�J�5i>��q����If^�gC"�G
e4��
�њa�؍y;2C���ܪ-#.������t[�F��+�U�以����8��w~黡w��[����޼P�w6o\���?"�a����F�wCooDM/��/\_����Ds^��v��B���UF��c%�~�-�M��?��󸎆�TBCo����ԇ_~I�}�[q���E�<sm\�����͋&�<��1��1�5ٹ��2z>�>!�/ ���TZW��?D�=�L��O�_ĴY`�@��N0kv�~�������в<QLS1C��.�
�MǗz]�yiܹ�H�\�!^s���s��-��!<�5���y�I�.���F�~��*>���E�������^�I��S��z=�;��t�n�31CRH_�/�}����I���1)`�c0C��:7Bz�]U��Q�/�_^��C�p�MX�\�w^��¦�����w���'���0�2T�����$��g���i�5�z��/[/���F�V��t���Fn���� jkOo������t����A$�(r�������N�� 䣃D�"L����u�4 D�!FW�݃���T�`���N|���H�.�S�Fk�,���-��S]&G
�Y�S���Ӱ��S�_���t A9_��0�ʀ5LH8Ӎ�����t�O�����py��7؇ =���O�{�bP�Lэ1�e����qj<�T�Ԁ�". ~`5�y�'3I���6�X59�B���]s��6�J��O�!uH�
~�W�!p5�Csl�^:��D`
}ʅ�^to�[)�V'ڨ���~H�Hщ2I�U��_'�/�H������ce��ۛ�ލ�yC��L�nߘ�c��ࣵQ@��z�T|ů7������>@21L����/�_[=�����t��=������-�ep�����%����p(sk��� >Ľ�\ 6o������N���8\V�+��1�km��3�p"|m6p%�����N1c���3kZ�H�D�1�u�pݏ�q<%_����5n2�v��@�DW����F{��t�0,� ��Ц����@o ة[�S��������p/[u{�����W��+���i����3<�62���PYL'��rHF�u�h��Y#kb���z��#JajX2���"�i�Y0'�l3;sm8n� �+�!�
��Z�����<r$X-A>O�mG�22�ᕗ~�^	�B7�����@�땉t�-y��U�V*έ��V�I�l]{_�`�F������>�����7A�z[�p:jܫ5@��ֈ��p�B�	�[#��l�؊~gWIPQ�������@��� � �k&��8)9���
�{�� T���!�C�|�E�F@�u�īkCMS���s@f"��JS繮��D�_t��4��4ewAii�&"(��1�vqp}��b��d��uO��+�3�c�����|5� �B$?ٶ"���������^x��bL�k���"M��ţ�����}%4�X >�~Jh
h]�+�s�ѕ8���Mb��܁��u�f�|�4K�����o��N�-\����oe���Z��J�Wg9�t��W��u�Oэ�c嚊������Q�b��@J�2Q$bJ,�K&{ݮң�T� *�����,��^&	���IpjM��^�t�
���Y�in0��ɧ]����8./�����!7�Ŗ���(�#Ie��L I�"�t$%��*�nd  �d<��"�dZ�IF1$@r2�Q�)�I�@ƐO%' �!�;�ɧ�3�� ��/�x���M{�����9(�mÌ�[�o�x��n�>x��V�,W��:ϕ�:]:-U�%�+=�i�^��o�\�f�:�h<�`�*rin�o�o�X����f�5Y�˗�wɑ�+:��KB�ʳ�d��F��.4ah���.���H ��d�2ڟ	c+�hg-lN�aU��S	O����.��[$-��㖙�����c�Z�ܸ�E��LDĀ��nr־}�d���b;��91�>[�sh���r���q�����g4_�V�UNG(X�i�׳�\��V���l:���p���$<��\���NP\U~
��H����]�N����6��=�E�����s|��̉�J�H��{���i���z�k���I^�S�UZ,\�`_ZV���yX�!�"��ei�f��,��������f��2n��_��`���ޕ5��5�w���N݃��V}U�&@�B�A/�4!�I���3;v���zH�1A[Z{u��՜$���	�b��e'���W��6���?O�<����t9v�;�����M���S��_��]ӳ��7��G��:��s�V&�y��W����x��~=��m��w��ą��������~�7w���Y����.��G���i�?����?*/�K�����������^7��b�M
�?���H����\����g�r����$i���G�߾�7���gh���G,��9�����o���?������� @��o���G�����������@���?|"P�e��@��?9��8����G��������3E?ҿ,�wg��?$@���H��Q�(&Er$�u��"�`�pa��$�T�")����&X1�(�X��M?�����!�gx�V���/$�F�=����?�Qi0Yf��j�w�Q�uG�r��2�Hʻ��q�������ϸR6�~�уt!���p�-]&����#�α���dJG~���4<�3��u���6�u��yM�1���d������ٟ�����a���q�x�()�{����%�O
��G��&����@��?(,��z ����7�?N��Q�`���i}	>5�����J�����G��ډ{)�,z ������<�?
���W��B�(:������4���� ��9�0��.�|��ԝ�O��@�_�C�_ ������n�?��#�����C��Q����?
��ۗ�?^|����Ak,�n)�ץZ̥S7Wn�?O�����z���^Z?���~^^#̚����K�'���<�>�e���ϧ�Obf�?T4q6KKƩQ?*������T��,�n��A�2kl��z���L���v�S+�b|�T��Cm�}\��������������Ϫ��7B�'5:�w]y�o�W������1X���l4^o��}����<w��2���̈�$ιSi�t�m)Y�j����h�ը������YG�.Ey��n�Ͷcwu��b/u�[� �����wm�@1���s�?,���^�.Q��E�������H �O���O��Tl�G�Ѡ�P ��N(�/
�n���?���?��X���7A����!������b���_������a&�x�Ѱ�6﮺��%����q�cX�{���T�/���5w-��a@�`�Gun&� �7�����U�.�d�᭥|!4J9�4#�)�$i�rS��#�5T������[���װ��>��eSίq�������7B���ڹ���;�'���_{��a�6�r��еM4I���O/cm/��9���(V�j�Uґ'r�{`�|w�ʬ���󊩞�+9�H#CR�'�zfoa��@��X�?���@�� �o�l��!�/ �n���3����#N��JG�$OE���ȑ�$1��a(�!�3>/�4�$�!�HL@�$��u������!�G�������^cz�(�v�R�x"]��~{��,��}^�V��&	����-���ܳ��>�ǻ�Iz�=������p������m���j�X2j�n-I}�in�M���*
��K��n�9~T������?�C��6�S�B����_q������0`�����9,�b|B��������,[��zi��'B�;�3��Ļ��V�Sϛ�����S��7���Ԥ]��uL�����U�9���(w&��<��%d'Ik��ܞS:�s�6ڕ�N��y���.���<�������oA�`�����xm��P��_����������?������,X�?A��gI�^�������;a��*��n1���'�ax��M��?�ѓ�e�I����g q}�3 �o��� g�V{�p*�U��e��3 d{?Z��!�K�l�4N�%=#g�vD�K��Ҩ�F���:�֩���.%V��Y�Jg��@۪�\�����N%+[.���D��w�]?y�
����U/3 l���r��J�W���$��+�h_����[�}O��:e�z��Db��5h1N+�X���j�Ё`�cS)���2�F~�i�Po��4ʦn���k���n])�Ѯ~
��pب)��p��%��G�M�]��VS�(�X*�Ϊ�=�/ϳ�ʬ��lc��<9(U�g�zc3��n4�A�Q��ǂ�C����C*<����������x�?P ���;�?���H�<��*��E�N !�G�������b��(��/H�%���A��H
�Qt̆�/�����ȋ1��e���t$J1+Ĕ��14v~p�����r�� ����Z�nv2�.7\��.Mp����d��Y9;�6=��[&��������h�`�����ة�ZU��mj⾔w��QZ��"�Z$���֢���s��G|gW3]�����*�^��m�̢����?�ޙ��$�x��X<�-?��C���i��� ���������-&��#����������A�" �����8���_�����������P�Z�m�Z˞U:Fe�z\��J������TH��&�O��:m����~_^#�S�}9�&~Z���}����>'�?�V<�����Nl���N�쭚{�L�����xmL�;ݺR[6g��0︣�ߐ?r&�<�[�h9���Q��{�~�&yc��*MSf���,W{�z��m-�^Qέ,���C��m�9���z�ġ�Z[R��愮s5��w�Uىl�j�*�6l�P�dt�1+�'��K���+	���β��=i�F��H���V��*+}��FnJ��!=�����Qe%aYnGƺ,p�g�����q���[�����e�ׂ����7��ߩ��i��C����o����o8���q�/�����n�����q@���!����������( ��������[�����o�
|���K/����	��������	p��$o��P�������?����B������p������G��!
�?����ݙ��H���9j���_�`��	������.�x���M��?��!��ϭ������0�h) 8�����@� �� �8��W��s�����X�?�����!P������H ��� ���Pl�G���#`���I��E��ϭ�����{�{����H��C�?r��C�q�������?:�����G��C��,>��jC�_  �����g��0�p��:����>�� 2�8�x��J,����b��'B�_
(��%�e9������8�?�S��o��v��#��i�ç��Z;G���"P�J��%7`�	Iy��4V��4�<���P�ت��������Ӱ��nܑ-U�;۽�ڮ�Y���T�U�t�u�*qB���{�;ܑ��c�����$Q����Z��-:��P.k����j]2^Ċ9^������K}�1�?�����l��������C�Oa���>��sX�������!�+�3�k���JY��WJ�ƚ�J�Q�֦��ԩ��e�j���֗�c�׍g��s�̶֩J]z��d����`L�n�I|�cSv�;%�v���p}�ʛ����-�^��d�N�,����Y��x��7��!������O���� 꿠��8@��A��A��_��ЀE �w~����A�}<^����_���S����-�tv:݋Jb��r�WI��{�vi�)��U�u0����x�1릻���a���g҆g��p$d�b�H6��QK���4�T���y����F�IS~*�N��1�e'̈́_�'����VjVW9q����㕾x�]�N����nE�M�|/l�D�(���<�M��f��˵r��c���)Z R�l[���"1D��-�i��6��f�P6u[5j�!p7�f��43##����84�����R�9��D1:����R�_T���Y)�dz��k��6̬<Z�9ac����x'���Q�}�<��W��Ҥ@����I���_$���>�������O����������o$������%^����:��$E�� �O����/��h����<=�*������<�w��(�R��ꪪ����~a�����3)IiFc�1oN��@���Mv��?T��a�*�>dܴ�z:+�o��aV�kʏx�܏���5�g�z�x�g�S���$O���%uy�\^\K�omK�]��$�c��P�f]ME�/uN}��n/l��R�ϝ�N��Ƽ�Х�^%gk]M�Q����	��J�5��e�ZeNɚ���]w�W��I��'�xoW���r��V����7�t�;?/k�$C������q}s���]+������Ğ(�"��awÔ{�<�~Lu�en'�}�fs�iLBmK�|֬u�e��&k�.Ozܜ8�B%l���Î�^_���` ��~A�s����SJ�D��e_ɝÐ��� 7���'���;?v=/�KNK����7��,�wS�翈�F�	G<���0)���R��e����$͏F��2��g�������c2�"���(���������!�����d$׼lg�'�< 	݋��^����]\?|�3F=������V�|�V��ȕ�Z����⣟�K���?�%�������[��?$@��C�c�X���m��	^��5O����5�gd��M'J[�-]��h����.��_�W������.	6�m��ٗr?�=��K�xE�o`*�S����{J������$sj�r�*5aǫ|��ۻ�fE�-��_a׫x�:|ydЎ�� �y��� dRA���{���y3�*�������^@�����9{�S��=C\���#����❮��ڼQv\��p��N���z�Kqt\�lX5��+*�#��$�C�u��:���S5��:�Z;6�2?)3L�J�+[�S}.������3�D�����8�{3I�G��u'862f��u���(��z�H39k[�n|,��M�9ϰɍQ^��T^)$����N2c��q�+����{�?P��	2��)��Iݠ�U��U�Hg�t:yE1�aj��jU�b�=��*N*�S��Z����"���Ϗ�U���@��=����ؠ]_�H��co�k���4�GrX=���?Ҽ�p^��~_����V��_��~�S��o�c���@�_��n��/d���i�/��XH ��������2���LY����`7�?�C��	�4�ç�ڇ��s���o�[-�������?����a����C��u�3;���Xw;��D�0Ađ��H����Sg%�:�����&��˶��m�d%��3WȷN]]g���+W������X\k�;/}������TΫe:S�,u�k������ɢ�����i�����}cz�u�-#Z�wQ�)Z����U~�F��w�N[�Xxl��/�?
���6���˼ϊ����e��{lS[��#eKl��ܗ���kZ���-���;yb�Ҿ��&'�e�m���>��i11��t=/}A2�*���n���`�:�U�U�!�k���Ú�w�#aX���1��Զ��d����"�?���ߐ��	���u�������E�X�)?d���Z<"����d�����	����	��0������p($ �l�W������1��\�P�����-���� ����������A��E�Y�+������|�Ob�g�B�?s����!��I���  ��ϟ������o&ȋ��q��� ���?��M���������������?yg��?���"'d����!��� ������؝�_���y�?(
��?��+�Wn� �##���"$?"���H��2�?���?�������Z��/D������_!���sCA�|!rB!������a�?���?���?�;����2A��/t,H���?��+��w� �+��!�?/"����� ��������B�?��������[�0��������E��
~���������Ve����H����Y#R7եY�R��T\'i�4����H�aL��h�}�V?�E��
}�C�6x���$	�JMa~���k	l�kK�i'�d-�[���ױ��$,Vӱ�~ߢ�k��~�k�?G�C�T�oLM���'Vt��m���t����A����L��ݸ�K=vI|�F:��TH��U�JkO�=K"�8i�Uf���Y�ʛ'����X�W�����M���C����y���f}��"����"�?���<���OI�w+<.�������q��&��8�St�aH�4�qM7�iܱ�ͼ�3�H\�����5�ɺ��tGkWӃ� ۉ���F.��{$!�pr�T��a�g:�����x���H�N��^�V��S��Z
,�Ň�<�!��Z�����oNȳ���'=��o�B�A�Wn��/����/�����9������}��*8�,�E��g������+
D?����,OI������?q�����K�s"��p_[s��@n��`�z���d�ko�>�aTw��N{�1�NUm��jެ�T9�8-��xZ�1!f.�sy��I�fn���b�ިK����}�6�A��+����,yQg�t����m�]>k��X�|MV�Y�����s�B<����~�u�Y�.Er��� ���-(uֱ�R�|�+�''�Od���������.�f�P�n-������l�:r��	<"��S9�M��;�vuL��	�I�#M�]]��n㨲����^�����)/�u��r ${Y|�_���n�?*L��	�o�B�?s��������ˋ��'��������n�?�P��Y W�O���n��?����ߩ���L�;��Z<�xD ����������E�p��Y����L�����, ��������B�?���/�L���� s�����
����Cn(��򏹠�?}[��A�G&�b��9��P?��Q����㦧��f���o�?�Q��z,�_�?b��#-�@���w�\��~�Wj?���+jgmn|���^�~�������+N4l��3.6�=��J���q�Gjt���˚�w�.&k�F�q���i�:��f�/��qA�a՜�g��X��+����ֺ�k�/r��WՄ��p,j9�ؔ����0�*mw�lO��8��SV���l�_��:3���$�cם��Ș1�z�����Q���8֑frֶ���Xد�8js�a���8x���RHT�ۛ!�d�^?΀A!������߫E��n�G�����
��0������/a S"�������& �/���/���7�'a�''��>.�wS<$ �l�W��0���P ��s �5
�C�n�R�_��������t�l�;r<�:Q:֨=�P��������X������6�;9]��� y��C@������=��v�*�U����,~wؖ�y�pWS!���a[��'m�veb��.:�������XkB�~ ��� $-���A��V���Mٮ	>��e�P�VKېhOA�;fe[k�s�jZ��9*��i8V��;{P��JG�8$��˚9���X��>��fB��w���L�����x�-�����_������ �g���?Y#]�0�I��Z��Ʋ�i�IaMj8E��Uk��&�2�iR��1�Q�2Ē�߇o����Q����'��g����Y0C���Zk��32�����j2��Š��kјG��u��S���h�`�u?P� �:���z�A�5%ǶoUT�s8,�\u���<�)�s���r�@�L0̀�� ���V�h�~-�����g~ȵ�O�ʻE��!�����������"�I�wS<$����������fj�D�')�Đ:�&���x�N+;D��\�D��5�����ڍG;���:�l�=r��1�jN)ďNCaBͰʄ��]�:�y_i�bD]I�I��ho���oBsv�H⿯E1����/*����=r��u �������� �_P��_P��?��������(��/'|I�MS�g��_��}z�z&J���4�0�&��o��^j ����� ������
��F�����˼��eŌ���٫���EcR���|�!k���U&:��p�l��Uʵ�y��VS�CEk��E���r�ϭϟ�<$�y��ƍ�����Un�s��l��	���\��?�@�8O$׏Z�_�J^4֔� �zĺ��3���}��bD��y���Ul�Q�Y/f�Fw�O��\n|ط���ό9�8MX�ہ�0:����D:{���b̞6���1G�6����BH��G�P�E-�>�ӃМ��5����^�װ��`���oo�h����):~]�����D�}��IW(��,p��-�+%��@��һ�����O;����&�z��ATYn ��yQz�cG�_~�M���蘞�lMgc���_N�"��cB',���#q���.=}�}��.���t����U�36�S�\������I����[������-�|@�_���OI$>�y
�?�_���)��矠��x����Ts<TSCA�Q�NT�z%�	¨d�6�w�/*��M�ĸ����ЈJ�C�)P�Rd%}Fr��	=�'�.~�����e)�/�ᩮ����c�����x�����o?����?�Y��e�*9+���_���Ӈ�A�	)���eC�y{��1O'wSZnc�[߻�K��}�j�6�6(5N�l��e��#Q����'$9��t59�ּ4_X�턼���9�U�$|h���0��OIu8b��#�-tǣ_�{��'y{W3��A�ޖ~��ޱ�!��0��ݛ\݅$/_��]�9�C/��`O���_�ϛ�Ǘ��)�mKwb��b0
KH�srM�5"�?6ze�{D�^��u�߻���_���'w�.���݁�'���a��vDYz�n."-B؇)�]�����~���Y���N���_�����>==d?   �b����� � 