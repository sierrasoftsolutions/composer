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
export FABRIC_VERSION=hlfv11
./fabric-dev-servers/downloadFabric.sh
./fabric-dev-servers/startFabric.sh

# pull and tage the correct image for the installer
docker pull hyperledger/composer-playground:0.17.0
docker tag hyperledger/composer-playground:0.17.0 hyperledger/composer-playground:latest

# Start all composer
docker-compose -p composer -f docker-compose-playground.yml up -d

# manually create the card store
docker exec composer mkdir /home/composer/.composer

# build the card store locally first
rm -fr /tmp/onelinecard
mkdir /tmp/onelinecard
mkdir /tmp/onelinecard/cards
mkdir /tmp/onelinecard/client-data
mkdir /tmp/onelinecard/cards/PeerAdmin@hlfv1
mkdir /tmp/onelinecard/client-data/PeerAdmin@hlfv1
mkdir /tmp/onelinecard/cards/PeerAdmin@hlfv1/credentials

# copy the various material into the local card store
cd fabric-dev-servers/fabric-scripts/hlfv11/composer
cp creds/* /tmp/onelinecard/client-data/PeerAdmin@hlfv1
cp crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/signcerts/Admin@org1.example.com-cert.pem /tmp/onelinecard/cards/PeerAdmin@hlfv1/credentials/certificate
cp crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/keystore/114aab0e76bf0c78308f89efc4b8c9423e31568da0c340ca187a9b17aa9a4457_sk /tmp/onelinecard/cards/PeerAdmin@hlfv1/credentials/privateKey
echo '{"version":1,"userName":"PeerAdmin","roles":["PeerAdmin", "ChannelAdmin"]}' > /tmp/onelinecard/cards/PeerAdmin@hlfv1/metadata.json
echo '{
    "type": "hlfv1",
    "name": "hlfv1",
    "orderers": [
       { "url" : "grpc://orderer.example.com:7050" }
    ],
    "ca": { "url": "http://ca.org1.example.com:7054",
            "name": "ca.org1.example.com"
    },
    "peers": [
        {
            "requestURL": "grpc://peer0.org1.example.com:7051",
            "eventURL": "grpc://peer0.org1.example.com:7053"
        }
    ],
    "channel": "composerchannel",
    "mspID": "Org1MSP",
    "timeout": 300
}' > /tmp/onelinecard/cards/PeerAdmin@hlfv1/connection.json

# transfer the local card store into the container
cd /tmp/onelinecard
tar -cv * | docker exec -i composer tar x -C /home/composer/.composer
rm -fr /tmp/onelinecard

cd "${WORKDIR}"

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
� �CFZ �<KlIv�lv��A�'3�X��R���n�Dz4p�#��I�%��x5��"�R�����׋�6�`� �� 9g����!�CA�S�"�$�5����&EY�-���lU�z�ի��O�b�؊�F�4l15iرWW�Þv�|JJ:�$����Ғ����� ��$�� �N��K(~N��[\ۑ,�.9�t��'Ý��-�زUCϡ��u���u����qB�NX9x&鎤���ӥ����Q�I��MliX�`+6j�5˱J�"��r|9�#�]�t��뀶*�-��� ����.i�n��y�ܛ��7������F��6�Ν��L&u��C��?����|*q	�Ν��-���O�����=t�S'��'��� Z�&�?����"��G����Z���lõd��K7���E�����yqk}oks�Q(=�?~F7���5d�x��i��`������K �u��T&D�P$bZ��H7@�,�}YM�ꛖ�7�̰K�b�uQӊ4;|U/p���J�_H
�T��B����!%h��""�ڮ.;�"�+9�@k�tY�gb���ru]�;����N�c�7nrO9�Ư,�P�
!�F�'79�����`���p=�CP��a�k���#��8N'��5�S��鮦�T�Q�|R�\[��$q)H]8�z�rD�,d��Q�M�>#R\�h�F�dI6�c@�K��P���L{�O��t�Y��1��3��E�l>0vd�����ɠ�q��X�@u������Vr��)2tmH��.� ���vI+�V4(��{�����DxWx:]��j[��pMÒ���5,;��U�.2L:9��0��T9�5D��Þ�1*{2bᛜ�h�C8#��!xtb�`����%
�k�&p����Z���NQ��h��@Y8<P�ے�)�����m-3��Ț�m	pZ���T����<�_D9���M�h^^�̰��\��S�O&d���$����?�����"
˓��k��úò3[�T�AmH�fdz$����YR��h�e�4 �1�!�������V�Q�5W>ׄ�n���^b��ח���]',�\9rIo�{;��Vy�zk�l�5{9� Rm��6vnC�n�=B����0���5�����f�qF���4�̒��q~��b���,WJ��͓�� ��;�B7l���7�a��
�bc i��W���Q<�}|k�:� ?B�����W~��,�?F����'��CU��%�������k���"��%29e��� ���oy�i�O���'������#�����$��"�o��Р����xb��x�T���$������`ra�^�9>��ۤ�;$$ �h<��Z�̨��u�A�@[�Ј�ғ�Y䐏�ipQƁ'�`�A�k���i���Cxs,�*C�J��>��&� �AV��Y�ki���8���Š�붢�ы�<�tC���?tF	I��5,:�� F�?M�18]$��tqD��Y��K���c)@x�eK3��+����64��FSL���媚�,��b���L�����ae�#`��A����ĺ�uY���`�A"���#nHm�s��&>��F7j���Z�S-�>�Z}����Q�Y�9��ot�������2_���e���a����K�:�I���"�����2��eC�]����� x5Gp6���Y�e���?1��S���v���ЭYYR��8���tf�������b���?�UA�o���R�T'���`��2�)�m=t��h!�6��f�"4w2�Uf��Ԇ���x��ߙx:=��}����G\����i�ߛ>�g�dR��?ө��_D9����[��?�<O�?��3)rN$����b����9�5t�V-�Aز�62-Uw�����+v�#G��q۶��7n���;��hKE�4=�(�?D�s��Ǻm����QE���v��a�>9t��H�M�u��S��i�
>��4�z�6��	Pv���j�e�=��������ZZD�����x^1��v��'�9"�.�̛�qa�t�V��n��c,Z��I_�##C �u��������f�4�oa���\X��j�����̢���ox� �m++(L��#Dg��/�C.���%��Z�����]�Fz���{>�S�?���fa���[-�/����C��2�n+H����]�x�޴'���MB�H���2F
l�s��⚠D�}I=���p�T���f�j�>Hǿ9�A�l�v{�n��Ͻ
�&Y����w���06	B���*ϐwلp�3��&��@��ca�s�I�
4�gj֕tk�w���LXģ��ᣘY69��#xo	�"xX��"% ���Sq���IG�`fbؑ�N����q�cc:���U?�%`щQW�l��j%P��V��Y]-������1&z����i�"�;M� ��$�}�n�5=�(=�~q[���鮲Wy�T�k�:���2x�n�M·��9�{�[����{���S���<������"ڂ'�^,G��|���j����#u(z�f��Dn����|�k��A��)<q�9�#|������*��O�^����×��E���i�rWi����q^�H9������q�������v�|��ʋ��(��3~!����x:����i�|'HH����υXb��R;]����2�H��� u6j`�J�[$��V�,r��z���j[�`���_��D"��9J!� ��+��j��in�ӵ$�ޮ��lԓ��K^��PP��j�l˄}���ldJ� y�x�^󔽃��܆FȞ�����.!���&��kXǶ�1	!�>7���'9���Rd�C�' 6����G�\�hbb�@�� ���no�ˈ�1�q��P��v��a�*47����>�h��*Sj3Dh}i� ��K��0�@n�_Ǜ]���Z���*�{��W~#�QҐJM�Q�����W5�b��0�$�5��!U(�g@�ס�Sb�r�B7(������V�6�q"���1E�� �k���t1�ʵ���S��+.�W�uF>��;����"[TP�m�	����&��<�	�K8N�'s�J��6?���g�i+������X$����g�O�~�,�\ [�H\Y�S�D����}�r�G@A�gQ���/⚆6ܣ����}����L莏��"w ��cDP��9+Clj+Ȑ�Z:��ML��TgHg-�'�;�%V�媬���C0VJ�|���'��8�ߦ������?1��OV��R��{x6�\g�;��a��Sv1�41��|6��I[=���1&l6�jIu�A5鶅�{��G�p�m  3z(i.��B^{��5J�	�H����2X|M��	l�n�N٩�S�ؖC�x�5F�R�Yެ�>��XC%E#&� <K��#ȏu[b��"����D ���'\�'ڰL�w�~���W��C,�I͞ըdf��J�����O]%U����3�'�R�7��0ݕ
H�)L�=�a�EE��m�%DN<��������Æ�0~����N����i{���ǌP���x(�`Ob�R�0ɳ��l��A����w�(6jT؉���☈(� UX_@3�{�@���Y ����,�=un����!��Ajb��D�)���!3Y���m(��i��m4�
�@�뱥JK�8f,:vq	���.�J>�]�f_`�b��Ν?$���w��@�dn|D5��{I��j���M �`�u���X )^@�D6�����q@�0��6�k
�Z��*8� N�X���� "v�p�ƨ\�ѳN�p&s��)7��(}�5��g���D�Qj4b��(0O����-(��Dr��^��݆L}�3x߿���d�|��q*��ń)8/&W��ڬ����X�8����2���O�q����TF���K���)�����q���s��+��g����ÿ:u��8ъ�ɤ�]n˼�'�R��N���l���
I!#�$���d��M$e)�Me�|+��Z˩T���~�7�8$�~�{/`�!.t��%��	]���q�]�Ї�_�B�w�����O.O"����c<�0�.]�ء�~�ʷB������|�,n@�C��e Z�+�0L�`�������x�3��+ؿ���}���8e�?��O�:1?����������e�O��[�[�ߤ��ϻ���������w��ſ�������!�����^_�3�+�#���b��||7�N,',ťdBɤ3�O��LKI�Y�N��-����R8�����jK�YAI�������n���׽�?��?-���/�b���*��/���A��q<����?Ƚؘ�퇡8��B��A�?���p�?��U٪���������}�;޶I�ލ��/����Pj4˫��,�Z�R.�����{�_΋�r�x���]^޾�h���8e�o��Eq#��<��o������?���>W��w���R����Q�YB"�]*�+uaՖ<<�{)s�YzP��i[~P�n�n��p��>H�K�U�[G�����:w+�V�^�JixmՑ���^���,ɕ�Aa�A��+�\n6��W��A�H*����~=U�(Aݐ���:��^��{�Nu'/�6Em�YiT�%6�r�ow̇���Ӻ��nU�m�>߄!$;�^�ի��P=�4��}
�Q�a���~o'����ֶ�]!�T��Z���Ҡ������z�/�w�7����xA��X����X�������[壍{�|O�����KSN��d״7�#��-oM�ְ#�nޫ?h��:hqݣ���������i Lu�j���	��xM����"�}g�W��,(�@>qw�˯�?�~�O��x�/�K�ؑh�ד�r��Y��I�.u���6�'ғ��^��5���z�3cxW?hw�'�~�㏷Zl ʆX���~L��w�R�Sq�AvYK�R�o��[3Y���{�q���k�i�v*->��v⚾,��tss�Xe7K\�]Yޱ�b5�R�x�\�r�5�k�#kj�UwSߩ�*�����,���>=��|T��U�f!�Jag�2(����f��m�i=�wWzP��۬Mnw�Mͯqro�F;��kM��ػ�ű�<�F������v��d�|(h_�����`������6�1�`����u�"E��e�s���$�����������t���.���p��y�9�{��'�A�w����w�C�ˆ}��(���u}�b�:���{O��CGU'VG��0$�L������c�9b��KБΈ�SX���Ǳy��F�I0��{�)�"����+8����q7�c���Ê�rm�j�8��ҙ�7��z5sDD$?�̖!��Y}lv�I����S�X=��S�E̗U��Be�l�}\؉~\[W\����'_�XKڶ��r�Z
�xe�1�W=H���������֚b%��V��8�M����:��h�`�B**Uܲ�
3?�֡�8�Ehs���aM#!N��s񲵧	�.g�"�K����vܡ7ܠ�K�N���T�w�ye.,,A��Z�P��T��8��6��b��@�`���ЫZ�2�� ��y���|v���#l�Ң��!U�OZ�lwv�L���7p��q�����>�J*�޳C�Ğ煞r\=� ��aۇ����t�?ݡ�o���)y�mY�^�#*T�4��h7�T�9mV����!�te&XBp`J$^i[x�Ot��B��"�[������%�P�9�9��a�ۂ��wh8����cġcCm�5�ԙ���*4�"S�����m>��z�O;��2B�9���)f�O��u�Q�d��n��&4�=��ƞ�M7er*<��N��t2~[�˃%��������>{��Ľݨ����{�G���+N�O�on:\e8|ks~p�����:x�W�������y������_z�?����W���E�����
��]�n��������ng������q#����¿~[��oO�'��Q*��T6�nc��7#�&k�T�juɁ�\�|���1��3�1�s��~�ĕkbᅘH��sA�Q��!x�z�j>g.蚺�X�o�+��2pWa�Gn$�{�P�D��c��s,$�6p(,��hX�U��#�*�&9R.�[iM6qsS�SDmLa��U��n����!nj�N��h�Ǚ����"����;s�C]�i\�L�*�_�e�wd�ɡ9c��	�c�g��z�5��L�%���.x_X��la?X��L��\�HQ�%Η���^E�MF��L�I���*ó0A�ݍ�]�F�a{:� ��v)|�m�vI��v�@�+vc��C���Ґ��C|���YݔF2^r$e��V;���?�ӣ��K��}�ZO.IR{�)�z](���������[a�c���ȕ=�9
d~���:�*��)|o����ʏw�d~8&]�O���H��;���~��Е�1���w���mN֚���[Ƚ��G�(�J3��֤Yo�=14�j��k����RqlZ{��ʘ�!�Uw�~ܚ�i�`����df��K}�!��RU!�'������BY�ʜ�0q����XN��9�ӭB�}��K~����o]���v�t��C(�^J�e�"T�?�Ҥ!�X��-7]��q�96ڃ� ��F�X̓⩵�+Bu�j���^��7檁$P���vq$���0������N��������m Q��T[̺�V����\�����$�Xdnɶrԏ�C0�_�C0�`�����u�c�`�J��1�@����3Lkw��(��Do
P��M̩@�/.d<-o��.���/Ě0��SK�������P�&��z@��p�D���Q�	(T��3�X�Ֆ�}l�H+�Ś/oJU�(�\t��+hl�Jոü��¢�z��Y��eB��k�tL�o0�.�m2�)�OP�E�z��0٠]��X���5�c�%�����B��';��wLZo��Pg:�R�V��C����L�~]��\��.BO����`�����4�_C��hіF��j�8,�:���o�_&���,\����7�/�/�E4�S~������/^A�����o����9���:_�R����9z;��Я�d
�cM������=q6��Y����w�7U+L��b&������D�C7�y��?@���ފ���h��J�O>�W�w��N�K�77�sZ�T 
��߾m�[�H&��+�� �g���dI�S^��_��?d��7����x���w-���x����?�������?{N�c(
�?�)�)��>���`��"����������F��~�a���������_���C�=�����_ת��6ނ4���O%�?�����S�]�'a�H���k��х ��?���������SAf��Ա��� ��Ϝ�Q��G ���L�߱w�A�x& ��Ϝ�1��d�\�c�/6�Cr����I���������N�����K m�m���wI�Ⱥ�~X�B�!������K��0�g` S ����_.��g��M9����� @:ȅ�����H��� �@�/:=��1r�����@���L�_4	��l���������(��4���zV��\����?$��* ն@�-Pm�9ն������g�L����?K ����_.���̐� �A.�?���`��������\�?��/#d����.��+��� ����y��X�����|�C���v��C�(El�F]�񬁇�	ץ�.���y6m�!p��A�$���c}w?u��1������tp���-�s�E�ׄ����U���6fE8���M�Ir?uɽ����3�����E45��-�ڢ�G��p��LW��k�(��{�"Zd��rX��ֶ�#�1�r�@��M�lY2�O[1��_"��b�ug���˜��j���Bn���Me���y����gv�,�G0��!��������GvȔ��_���f�1�X�������������j�f���PLՊ1��+3V}�kp�:���~O?����7j�Omg5o���t�t�)���Ё7��f��+��R��SZּ�@��
1�E�x�����cq��\h�-���"����oF�4�;�g�)~�?�b���� ����/������j�h���G������K������[��P�hUY���jy�N 
�N������>���}�<[a�"��������A�m,1�2o��DC�G�����M����[��,�5�]/6�K*���/��A�ͅ�Y���T&�`�Y����am�jBmd��Ra�kuv��?i�
4�������u3�+�*���Wi
q�e�v5iw��҂�u�D�
��Xd�	�'j�s��i>��*L 0�߫�r5CMt*�ƣQ�hЫ���N�׷�`�+GI����9���Rn�F����$�#�V�������k�s�A�!�=�?��K=��}^s�4����?���X��r���=�꿤�T�y�- ��Ϛ�Q���_a��i U�^s����]��� ��
�����_3���E�W��_JHE��}^r��_������E�W��?%���`��|!������ ���������迏���>/���/[������i�?��%_ȅ��g���T �����_^.�����>z��98�|"�����@��T���.��B���T���<8��1!s ���5���=�$��4�-���Y�?������e���d�d	����3��b�_��/%��AZHH��ߵ��J���� �?�����{���
��a��ܐ� ��������e�<��=g�a���\��{�?P��c*x���|��q����4��0b�`&�;��J��I���������<��q���3��i*�@7��r@ʛpY�7�ޜ�,tX+K��Hj.��֢�+��S��Ȧ0�K�m�e��ٽ�5T�ΰ�:�m#�ƒӝ-����(Iy�(Iy(�3q����ڤ8���!���`��L�K���a%�73uӶ�I,�SU��r5r��`6��9�a��M�E��"���ً���\�?��@�G*�^���Y�����r������`����+��!SG.��=�1��S���?�����#��@�e��@q�,��������3C���L���`�?3�����#���r����@�e�����݅�|�������/��!��a����4N9Fyi9]��ۨG�6���z(
�i�@�(��ǵ)ҥ�: �?���	#���������3��lI��-��&��_�2��(�"����+8}�]丛ǱPeE8���M��O�>+��^A����D��Q����~�!{�ۋ���$��Ʈ��w�Rm����V��.����O&�8&�x��1�R7��L��Z��M9
�����R?�
��bȹ,��H���~�⦲��s�<�P�3;d��	���y����e�\�?�������}s��Y/y����Ç�s=1����e�4�!�4�-sĪ3]�G�z���<�?R�vĲm,��b���z�OJ\��k&-��.t�.�u(����N���X}��ݨ!�>��V�9����4��^w;�Q����|����/E���������Y}����X��2���_ ������2�0�A��_FxL�����[�W:Ҝm�^	-�#3j/��Ų����!���j B�D��<�����D ��eiE.�EًCU�M֖팇�C��A>�и�9�~��v$�wW�p�5�"����U�9�P��H�_T�v2�����2Jtk1qU��y�սJ��ǲZ���ɘ`(2���wn͉�[��X5r>\���*�(w�=��������ӓ���L��g���I:�������ۖJS~9/{�4�2y��73���޻a�Wt9l��^�S�b,��zhIx�u�lK��O����/��w�ь�k =ѵ���/b/H$��Be�vGK����H����9�!]�����:i^�Y���b��D΢��}w�	�#�3���;�m����.`�t�����Y���_�!�'����E��0ӫ����w��b	
���/����`����ﳞ�L�Ft��<O�Tʓ���7b��b�$IÐ	��x�����<��I0�W^������P��"~e�_[cW�H�6h����e�,�Ɖ���*{�"N�i�o��?l�E-�G���{+ux����������O3ݡɫ������s4���P�'�W��,N��� ��s�m�A!��MBJEDp}�f#!�i'�4�8�Ҁ�B6b"<	"H����~u��G�_�?$�J��b�T���A���e�c��&���懤s
�>��19����{]��c�2��r�[�2���R��?NB�WE z��f��������/���?
����������S��$/����x����?�����2�/M^���Rp�QP�G0���"���Cq��U���CP���?���G$�A�I���'���d����:8*���z�0����P���6�T�|e@�A�+���Uu��(������������W��̫��?"��Q��ˏC��'�J��v�#�j�#ÐP������,&����A���<�6�ˎ�%L1wK���2g.]�AQb�XJU��Ƚ(�y�F�'Y2��.�?F+f3qϔ�Z��i�d��+��x�<[�����?yjB��6���"�Ȕ��"*�V@�=���u`���߇�|��q̽lQ��ou`'���G�W3 ��)��Z����hV$��;�Z�bQ4��9K����6��B�}�l'�� .{k���ͲX&{���<[k,Blzi���ؖ�D�]�z!3��l�e+{����J�$�V���L�*��\�S���Ծ�F|.s���xy7��2ZѳA���+�L#�����v�����4{���ܝ��t��_V��뗴E=�ϻys����$P2s��~�\����ن��8jM.F��ɺ:^F.�Go��mQ]��q�N�_�}�8
6HM~T��[AX-�G����	u���Y��@5�����_-��a_�?�FB����E��<���i�}����	?�����G?�����j�㦤��17˕�r��+����/����_�*���_��$~�Zbp��tҚb���KmY���\'MG�{�Nz���O��ϯa�\
o����2��\���Ԕ�{��,����#>�TH>�w��"���z���4 ��i蘣�{��lbxsf϶��g;I[wވ[�n:	�h�p6cL���M��!�fܷY�V�jVsǑ��H��S��}����jYK4��*�EѼ��^����)�.�v~p�$]���]��j�Y�Hz�.�YsFv���)�����2<Mŕ��Lƀ�d%ۆ�$���"0�М���ҙd���r$帙�ِ1�|eu�q�ΕM��)p�!6�Z?�gg��cl�����v��Z�/� �������p H T�����B���_�������}N$ �Q�ϐ��a�~����������r;�-H��Z��/my}~}�OVr����>��m�
v+�'5 ��0m�� ��B��� �O��L�y�ͻ� ��B��4�����U�s�N�m��E�g��9n4?/�m=<�\�aL�9-��<���n@�v����xG���̃��?����S����6dQ�� \�:^�=�X�Z/痒��XgKj:ؾ�>���+jGZ��AilB�h&c�^!�����x�0;3Ծ��B��q�����-�DQ{�hƺ���E},��V�.�T^yv��.ɃZ���+��_p���J ����Z�?��ʨ��C b������:�������_m��������$�(�C��H��>�%�����k�u��|0��?j��q�C<��0�#��p>�$�萏���`X>����( x.B�!�i��-q���`��D���o8��ݮd䳦0[�,���>$Ɖ�z��q�n%��6k��m���;������..�@�����y#L2�-���f�L{�0�H#�Y&O�����G&d�͖{8w[��'�D2��)����R��?��������%�VI��������?*����\m`���ף���:~���G�ɜ��S�kc���4��y?����3�D��?�e|�N��åuiҽ�C�vS=�-�A:��u�z���S[�6��A
w�z�N6'U���f�ߣ�M3)q����zޟ*������OA��"�����?�������C��U�A��A�� ��8�1`�"��ɇ���>����������O��#J�������K������W����ڵ$_�Ub.ǁ�[f�S���[l���h���df�F�X�
��L׊8��ƑP����vA{FdgƜ����^ئTaY�Y7c7�{N`�������˾�ӷ�O�N���ܶT�����Nʔ�t�Ӊs��~�,�#QkfY?���Hj�<q��:�tYe:�cָG{�E�F�Y Me �w
ݭ�2�g��㐚����:uO~:<���]��8�t{S�Z��N��b�oĂH��F3�䰥�t�a���?�o�@�� ����+^k�����?�A��H���������H�a�kM���Z�I������]k*���W��"����W��
�_�����?����?X�RS������O�$��Uz��/u���A�?��H�����������'��⥦�����_��u��X�R'�����a�`����/�j���C�G���a�+<�� <mAq�?���!!��A�I���?�h���
*�o�?�_� ��P���P�_i�Ǽ:�����@�B�L�!N�81A&t�B,K	��,�PA��AIƼ��\Bl��b�Ϣ����
�?��+�?���������Cb�,$G#Q>����Z�}a-��L�m���n��M����ᅞ��ZW}����c������z�٪܍{8�L��w����K�WR�>h��B������]�Vm���V���'=�	x�� ��?5|�@=Aq�?���9�����O����/��?���T����?0�	������������d�_���	��)���U<h�Ôb�$"��(ay�O��b8*�h>	�8!h2���S���������2�_���l�����<h[�1r�mS3�=�g�C��O������v�n��-��JX��T�&Gf�R	��/}̲�}���ٜ���M��29E��;��.ٻ�R�G.$�q0[��Msق��[�����Ձ@�o�@�MAq�?��� ���:�?�?��Ӡ�(@��������X�������A��� �j������_����?H����f�� ���\��W��D�I��>=�����a�#`����0��Z��`�#�@B�b��n�� ����Z�?þ�����z��� 	�y���?�����G$�t��s�����Ήt��d/�,i��Ϻ����v������[[g�{��)�{����������$$Oz�L�Ԗ�f�����҇0m���T����P�8�Q�]]ҳ��/B�_o5�M��Dڅ<�k��,S)��=�W���X>�{�B6E�4��~.ɃR�ſ�x��ǿ���_��SѠg�v!1�x�8�,Xr���d=�.�	��,J������P��=�D���,4iI��;&�¨��ت�uA>������ʚ��n�"�{�`�:����������k����A��?"�f�S�S��h�͂�G���O0�	�?����������U�_��_;����������x����#�����������H~���hz��8�MI=�cn�+���+����Lqq��SS�̓r����yaMCu����C�)��\t���������bѪ}���˄�O�#��䎢
g����t���2��OZK�ט�BZS��zxa�M#�t�Қ���x��I�����5��5̛K�-���T����!��g��,��g��g)$���"���z���4 ��i蘣�{��lbxsf϶��g;I[wވ[�n:	�h�p6cL���M��!�fܷY�V�jVsǑ��H���÷�g��{�e-�|��)�)��sQ4������`aʆ�K��8I�lgw���nV�$҃^o��m֜�F���`����z�d�DSqe} Ӆ1`1Yɶ�3Ih>��'4�k���t&�=�	G9nfz6d6_Y�s��se(zi
�a��G����Y��[�-����Z�ă�O����:���\��]�=���v�W������#�V��!�E)C��1�3!�38#a�'tȇ\�QD�T�rI�NEl�P�	;�M������H�����K�7槙������bE^���E8mV�Р��6o��m��������c����ȑ�y�+��o�l�f���6�p�����n�I`����_��n�9N��E�>�[-�J��R���g[�q�:p?�^�WOΧ呛*��"���������b����)wm+_����V���6��)3��(���9�Ѻ�Q�x�����m�ϧKO=�;�v��)�s�����ӥg����?�,=�/�������K�A�o���K?��s�����fl|����{��劣�����UU����+e��l�����i&ר~(��	-O�S;�nTwD3_�Ho�֔r��"���'[};S����7S}R:�o:��Inb+͏���I6��^�n��M���3���'J�a�Wh\��?��@z翶���.m�m�m�m�m������lm�'H���goa�'���#���.��������7�Y�\��~ʟ�TRU�z�y���z�$���U����Ѳ#`m~�@�g���HО]z LU�胮\�Z����@���gf[�'�ěS�̜|5��u����E�o��w���q�nWZG�J�M���p�?�T��o��w�[��7�����[W�u�^�/�I��~�}��/��q�y�x���airV�*���%0>#ū.4Ҵx�����~4�P�t�R_�+}F������F�ݰ������߿��ޔ��~�6Y>��r��IX�i�Ϫ�˵ꇓ��{���Rz����qI�>�*�S#b�z_�|Ȏ��iQ+]��k��δ��ugh�g?:_�>�M�7�z*�qz�yw�W|ށP�ǧt��kc������O�f�[��Q�R6GSK�R+���5������٤�8_��ȋ��nV>�N5�6��Tf8ZOcV�GT�X:��rP0��@�6,�Y�Ұ�$F*�����3h�!5h_3�����T���Q
�S��s�#<�����:�B�B*�jF��6����F����)|ی���m�e�9!=�"�it�0��u�a�Q)�G$̱i;'�䝟��^7�b4���=L���e^~ƹ�^�C���?7 �!(V�4��L�☄��3�f �#]S4D$�B�_�h���%�yڵ8_�	9�2��n��j~B�)�H�����
i$�mQ�PˢSl3/�Ҙ��0��ض�!JPԙ��
]���bN�y�b_\�b�k�p���),�����A����f�!x�U������%�9�{�,3
�`�X��P�� �	��п�	N]�y+FG.�(vg�~��:{�7�ɷ��;�L���:P�ڎ��B{�9��`�}�0Z�
H B�ͷ�b�m��i��X;�m�G�g���Š�S���բh�+����<��������~S�.����W� [�](��.�V�}8��I���0�̉�'Z.J!�B�����P �*�T ��>��S	�3�e �(%�i^�_횑(Ng��FE�$*���N,��gӅ�o:�K��p�]�C>�W����#�N������%8�M_�]}hU�c��#ࣨ����u<$�u$�׍(QR"a�!C�q� �TݵA�@Wx��f�k:	O�t�C��)�ʬ��E�^�Έ�c�v(�P�v'��#�������8��qD[���+H7��@v���ȀvkZ@���[x��0��B	�&'N�8�=�,ItB�s+����lr	�1UU.a��x<��aĻ;7@k�������\3+&߱f|z���7���*��dS)�O�ҩ���GI8����2�2A ��В8̂��!�P�#f�L�OH�Qha��*�6Oœ����f$3ƚeh�����b�U+_���Ǎ��A�9Jb)XɛK*����>Ջ b	�^kdZN�Ӌ��
�Gh��A�= 1���oYL2 �xV�YNOK|-��&�]!��k6���>��vi��Mf��y���4�*I�O)���,���������J3鴺�ϲy��9�.�k�z����&$������;dr����Da���!0Шe֥�4V����r����k�Wָ7Z�j8�Z������������ʺnu�Z�S�+�V��>H�������v�}V�7*�)��N�� �s�k�X��g��j��N���g�f�r ���em�J���^����gdbZ�`�]��U 	s�$��:��m)�>X:n���★��,i�	<�z�=����/��G�P��$��B`@�r ؉%��Xlu�B������|�����J���r�UEf?�Տ.�q</P>.���Fe�h�Z:?
�pvY�W��Z�s��M!�H��S+a��4<�v�Qy�f�X󎞇�zb����&��*��	T=n�;�F��vtY�v>6Z'gлO�.�&m�ѐ�SA��\�Y�/
"�K�l��#���;U�R�K�v� �@eP)�Q��8/WJ�O��#����naw/�S%�_��'V̉)�d���< ����Tx��%�9�`Ns2����B��~\#�������w�˗��+��CWو�}	F�O�Us)~�<�j�c���,w�"�@��Es���9��%��R�<o�BS�dM�,Gup^)1d�]"�O��$������8f��t5��ltbk���̦�s���|f���(I��	Z�.BŤF9�/�돰A�;<��S�N�c%�iGRkr��,G�G��$1�uF�SB�u�r��N��5�{��|�Lfvn�@�	K��Z�x�e������uk?�֭�d����lv���(i���]�ٮ�l���?������v��i�$��2�A����@���r�v���ic��a�R͉qȿ����m����O����L6����#��[���.�xl�z�G"��,�!̲L�-Y�������<;cP����!1e��k�
���\~0)6�>�h�vR\��ӭ0�@iӚ�#h'Fw^E%�|�5�;�`;�l7�[��ɿn��u���+MTxB����-9�
�f�Ȏ�Y�[� Z��޵��suDI��( >�4�a��9gո��i�a��wV��O"�5(��vȖ���s���jd�U�#AI�;�}y��>�.��S�?R�aB�Eg��\�m,��c��C�1�����ܜ����m��������(q�uȯ9u}$�)#� �6����������u�4�O0���T���|j����r)�ͥq�'�����c���/_��m�^�&�"�0e`�h�{�_
�CY�#��؀�'�������}��e�@���@%�ǐ���t���up���J�:���]�)^�z�4ywF�́7x�Ԇ�eB����!�@�����b�U�'�&A�
�8��D�Բ�e����؂����Iv^�X�!I��o�M�_
�e'���/@��^��/���f�~�'&0��d�ͿIl���$�d��#�7�Py��W5XlF �c���Y����5�l��2��a/9x���4��G$���à1����<8 Q����x�#Ӝ�"=�����$ ��r-��Jb�?C��#�n�(�q2��Ů@�fu�$@�&W��?�b�:�&��8y����I��ʽ&�]n��<'��!�e�?�,��L�������>���*��w3ؘ��Mh��dM�)�b�V�m�p1�_�5��Ϋ�~	΃!�4�L\��1�Pɺ�$R5����e	:Hܐ(����8$�
��,v9���m�o�^� Z Q>�Eߊ̛�3-���֜�6d����L2)���a���{u `E����+�؉p�O�u|TC��7�o�ۂ�4K���PM5,�-����c��I��{�J�.V��u��un#�[��b3��pn�~�P�2;|�s%"�wɼ�W{NZ{5�����F����s�B׆�HS=�9k7�+p]�����uܘ�z�+����4Gc+�/٣����p�$eq���Z8�Ѿ5R
�L0������Aܰ���(p9_U<�
���2�*��T.|���c�кԂw���pЭ`��@ʗ'��K���[�^�s��K���v�,����J~/����������)��t�eR��=�&�L6���^��wSyJ�i6�����#w�Q����f�d>3z<c
���-5z��V�q�i�w�p������*���lv�^Z�ϙ�A�F�0YIl�z�$1�������4�c���̳��-"�d��?�3C���FG^K�R2�W���]���U�CM,B�̖�biˎ���*�;3��ǳ�T[�t�
���˘!�e�[���6��|44�l�R��K!��p5�s&�����S7FH�Ծ�6-�{��xl�.�f+@��S����O�tz����{��ƨ��I�T�ydS�ħ�G���۴2m(�?�m��?)~�+���L�v����i����tf�����x������������������`n�>����q0��T��	1dKМ�÷)P���f�}�%9�m2'�ێ$i�_o��Ͷ]�+p���)�:���Yܨ��ujaK"�b������m����
؉�4b���y��0e�Sq�O���Js�m\�AGrnaɽ����}D��	��
���N�C������^����p���
эu�.�`?��o��QJt���3�=�%��S2�B����n��=J�q�O������}5]@��Ϣ}q�
T �D�b�7qv���^w>Ϯ+��Ii���T����Is�i���㿩��S�w�؆�@�S�����t���&�"�t���T2���O���T6�C�/��d���1����ƀt/~r��"W�[�T�^��%��;�c� �]��E\2��hB��T�AQ���3�����)"���c�:6���%{d�^�����,2���������R�h�P���V�.�t�jCA�kʂá�ù*�|��"�5-���@�s��K�(,i�/Va�X����~7y чb��k+���y��-��@�>�OP�h\4q+YFƘ���x%�A���#s�P���sd�t��%�����1��SF<�+/"�PRs�=0]]%���]�U�Ӹ����W�u<�����Ϣ�rG݄�@$\�1���xA$��E� i��[���! Oc�k�}�{�tsă��8�uB��� �ZUzj*R1�θ�V�A�U� ���Y^lk�����'�&OV�~#!��	Pr�;��֫���Zx|��"�Z�3��{k�@׼	��^ - �U�J�Vd6��ԳN�/�=��B��op�ac�#�������p?yNþ~
��bS�S<������	˴mA҇m��Vא��Ft���y�tZӐ�g�<�A��*O�:���X|���n�4A���ٳ���������8�r�֨�~d�\#���"�����h*%��}l�TT3-,L0�i�O�XL瑭g���6�R��?�ˉBf�x�"��� F�g(�����n+����ă�"x�6u3�%�״wM��لh�����j1�_R^�N�[��<�*�C��̕d#�|���z���PJ�X���P| i;��}ehg�e��\��!��/�qh\28̂Gp FhF�7�L����m��5 `G�jx�>�=Wn�FB�'���k�qK�ӽ���g�g�ܶ`��������v|��4�%q'qb�F���8�ǹ9q�Ѡ�!��h-h^V��ސX	^ay�}`B�����`�V�KWUWu�a�_K]U��>�>>����?�������Ǯl��ef�����j]~�ݚW�[��9�x���q�64Tӽ��q�;��1ŭ�p[^5LE��v�r��Klq�{�́�޿�����K`��sI��V��趿jq��}Q�I�u�9���i��cs��G���Iy������a���Ë�]�/�<�-,^����&�j��h�B��̿��C ��_8M��}R7Y�u���\cAާ`
=f���<+�h�Ş��h�-�	���X����D�K�M�����+���l/�7Nj�O�O��-9�Q�n	�݈�m��7ϳ��`o��|W�?�X�;・����?���AC�H����� ��N ��6����ۇw��?���^=�|�C-R���R�f�#�6kM��(�Y�P%UC4�����*F����(�֢8��m�����!�
xikB : /z�����8^�ހ^��՟ÿ�}��ɋ<�up��:GG���:AoA�|�ﹷ��ͭ�kܸ/?�&t׭��M�v���6N�Y�뼽�y���=�K\���va���c���'�H0�wpt� ����R���.��7�E��[?�����>�ٿ�[_}�/��!�|3�k���r����x��.�X��?ĈH4��TX�"� 5�#YkDJ#p��܁cu
�5<�@Po�Q
mD�_\������՟|�����?�~��}�'S'�)��G�݇~߆�߆�|���0��з�8o�A��:���WD�;���}������>��}��/��M����ȡsAl�Ͳ��]����d-ۊF��m&����ڊ�pt���A����$�����K��7z;m4��]����(��/�&�u��sK����+�Ź��9����TlK�خ�n�lY&mʀ���N.�kWd�,�b^t��	���*�i�ڥf����'F/�%x��[����lպ�~�L�|ǉ9�
)~ʸ�_���E�RB�Z\WP���u8�O3�J?�b���N%�J@���&9GKuN�it$!*�tF!a�JΘn#=h���_�mGT��2�3-A�����l:�MJ�|"ԩ��<�L
���h�B��i�1�����HG���������YT����vx&<��������U��#^O�6?��:�jwZ=��HB�7KW�N��`���sy��yZ��ٰ6���TT^m0��&>i���>Ǝu�2O��:+��f]�	uR*(v��[Qzүrvjw�)���<��b�8*�/Hi}�Φ�7���qR��8k3�Y#��g�2i���)�I*_���T���uRyʹ�M�{e�&	�=b &�w�����j	�ϟ�L\�P>>������;ӂ,{�	�)�T�������dV�S*�f^iV������a�"Y%�}��f
�0�<Q��Y\wRmYf�"�Ł738��w$ol:w��LwXU�$#0��'����.���fc�h�I<����l�w�y�$�$��>����s
/Q�U���k��8Ej�6º����f��F/���*/8"E��\96f,F��FF���zg^/4
���ǉ�?\:Q
�'vB��O�2����!2�*l�YkvV젾���7p*���x��&�x�b�rm�<�s=�un��=��
��?`-ʭ�<G�-8'��ȔAӡ*���Y-�J�=3'1�G�h�Qk�#T,'ic `�$XLQ�j�1T�<D�^��M\".?`-�D�����4��*�>3������Y�n��N6����X���"`��(BC���Nv�(��*%�2fx�NF��
t9M���$:��ǳ��A(U%;��@nrj��l��I���̲���~߀~�5	߄�;���/��Yo+�os|l�]����x�36����F��Nk�n��\v�2��k[��~�fxU/��$�WWz܁�_��7�}y���w.9��7��.���	��k`+�=����x�>��>��������
��R*K�]*k��2_����<2�S�ex2_&�����O[��8����,zz�םؒX8���)�`.p�Yt�皹�u��m�K�^_Q�c�f��(k�z仭� OE)ɴ������c�!2��aiZ�v!!1s$� �K$C\?�����V��T�d��P�$BF�U�T�N�l���G��cO�=�6K�r7����,����2�]�Lt!�bY���t��a�
��Nstn[`d�#�DXd�B��%�a��ϻC�u�V��[����{���3�+�Z%Z�t�t
��z&AsO�Q�f�\9^C���X��$�)g]B��ZXu;�S�����هG�D�-��Z����+]�I,\D���չH8��K'�)ʵ��,U�aAP��8N��h:;�ǭ�����?u���������
rlN�
2�ʹ��lf��9���\e�i�יe̞[&,˸M�Sl���tם���:~�������N�d����D8�6!��ȼݰGF)��'�j��9���L��I�U�2�p�S2$�����&��쪓�V)�5��������;�j�&
�A&#�sD�F���T����̊4�����Ͱ�#�h�ԝ�xO�r���Ӊn6�!���\�N�� e��P��xR<#���ТEu����9-^-j�D�#+�>�,��$`"M�骃��'����N���h<ov؄!�$ݬ[3��T�$aFeV�{��\���t⿼tNddO�̎���t��U6ȱ�PL��R#��ĩq�$='N��4��Mp�%1�,�	���Z��c=�Ba����Z��=u~-P���{�@)$����)�f!ǃ�2K]��q�����,��IU*:��CrQM�*T2a���H�0�Wl�#�<:� :o=�r]����B*�<��i`�UC�#ˑ��$���P[C�un:*&&�S̻(�J�(��X�j�1�7�%�*��25�ѓ.�Lא^!�Z����U�)L+�X���!��4��|��̙\��KT!˙Y��ɴ�K#�z�@_su��-����m�ms���~N�Xe��I����.��F��X8�G�����/���j�f��#ot�^�6�l��/o��@�C/�{�=B�z���������{^�W��m�س�6xu�����Fc�C���ޤK�R���Mp/��Z��Ӧ��ju=��(ss�,�SmuuB��_�z���]���.�{���lF�p����mH��E|y*��� 7�����Zc�d_�]������#n����]��㿉
u�6.���.����_|��|�
�z�ѣw�'�N{�����Α�l���gz��,���m�-h��a�.=z��#/2�+��ߌ�3��M��M��}�Iѽ�V�C�>(�
7�#Z7�B=�n�zh���к�#�}�7�D�wqCW�C릾���M�Q��z�Z繣Z�5ZG��{����{��6��w�\[�����~����`!`���gԟX���׻0��e���������n\�������d�/J'���K H���[zRNa�� �W�w�U�U��3�c��ʱ�8-���ђz_�u#wA/�������jy\��V�G��}$�Jw�ew-:� ��La*ѷtYP9Z�����+]gz��S�����"�%m\2��IO���q�쿝 تl���~���~��#�o�����=�~���� ��N�m�-s�l�B<��E*��S%I�a�I��T�SF�F��,]�HY��K�91c�V��S���[�.��t~8aG����E�3��,��.k�B5M��bG�Iy|��LW�	4n�l�d)��X΢���0��gi.!�ZWc�VOd���37��S�\c�oG�RW��"(���z�?0�=�w������N��������.�,�;����U��X�G/�k0��{a�ad���	�z�/S&�}��]����?技��w���9��h����n��2�^��������_��S�����������?��.�'��Uo�`�:�'���w�����O��������X�z����=	��9Ǯ�����z��� ��N����a��$l��3��b/�?���������y!A� ��Ϸ�������#X��	����v����a�,��?v� y����@���{��!�i�'�@�����lsl����|�{��z��G������� v�����s�����ٖ�lKA���d[�{�>������O�O�J��W��������o��6 �������o����?��?���&��'���u�����������|����������{��uE�E��z�CH�QkR��՛j���FF5���f�F���`
&#L��=�W�s�}��q�����.�����_b�Ո����Lf+`�*���P�R9�`R��nO�Ȯ��Ȣ��fPt��(!4���(\��iC��a�F�'a"�&����Ē��c�M �Z����i=�6gB*+S��'���~y���������~������}������������O�_6��k���_����x����"��9�.30p�Tȡ�ڰ�dtݬdYrl��c�RX�)���62Y�ӭՇ�<<�u�HY��Hx\�'f$��d&�����H�Lo��x�1h'K��@;�N�#uʳ��wU����>�O�_W���+kO���_q�}��y�8 ����8ݜ�@�Y����;��t����^W�1�`V�U���߂�g����A�Wa��/����/��������,D�?A���?x�����k��-'�v�$�7���3�кR���_u���ߏ?Qת��d��ҁ���f�r�M�-U�7��+д�ꎳ�~Z�n��OZ�zX�d�=J�(��RJG�\�$�E�m��ݠQ���K4I8䢽.���-���k[[���c��z+��FW'Z����)�i�Q��@(S�G��z��}��-�{,"����Q��lu]�ſ��^J>��.�����Q�gg�ݭ�5��}�	-e7���>R��Q�GrfT(�*�Ji������Yז=����?�b�
L�jG�v�O��^�����{��/'��/����N��?`��h�H.����������(H�?����Hp����?r�� �?��G������M�G���	8���@.��m�G���M�G��bf��9���������b�!��_������Q�?�y �����#������s��f�Å���c���0�����0��(|����p��������k�_��"�_�3���X����>xy�kB� ��/��Y���� �����us������_8���_a(���2�P �������O��a1�e!� ����O3����������X����&���Y�!�����D� �E� �����h��o�?.�σ�ǁ����_�?^���o�Fm����ڔ�u'��C�S��j������s{
��:�`�?=���S������n������b���QP�M�>�$��m��î��uôLY�a#3��������e6�k�����n0W,���{u-�75 Ե�j@:��w.}�X�����.c�=�O��)���d+�S�4���a�h�w+�&���1�^����LP�jσ�4O��Œ��������w���ܙ� �XP���搅����D�?g�'俰�$����A���3�������?B�G����_!��C
��_[�����I��!������?B�G���uA��c8��]
���f�]���������;�9� ��y���IQ$� )2
'���@�"�3�,-+���$:�� �%1Td���������� ��9���C�?����տآ�m�g�o���Pm�6����ڼr�ܬT�>΍�f�9���nܓ�RwƯe�9'ҙ����8���;�t8��Ѣ�2�4�����ީt��r���d��];ɹ��ǋ�2��O��C�9&u�,��������h�ɠV�C#�v����Omz�f�~��E}�		�?��,����}	�?���@�C���P8�?��oX���� �����?����~9�Ϋ~۬k�	M���s�Yw�fVuXwTN�|���g�'v+'a���l�$:�h����\əfc PIv�}aHs}ɯ������{��K�a�2��_KL��^n��ʗi4<�y�߯������� ���@������xe������� �_P��_P��?�����XH�����+o��U�ŕ��9q�>��2[������X�_���z �I��{= ��B��u �E�����-Bn�2��R=�S�{Z�,�հ�8�E>)Ԣ��,e'Q�w��k�K���lIZ�k�<.9ۖ��W���g�G]u��Լ�>�<��Z�|�i�WS��`j��W�r��_ u�h d*���/�^#�es�y~]6��_>ҭh�e�Ps�ktN����U.���]�4��f��Bzdվm�C/R�h,�i��@�N�:�T��y^O�s��z�i�ONԋ6���&�W���H%kN�38�>[����8v'ވ�0�H��:�����������	�q���H7�"��X���zz����ߛ�_�(J��q ���/�����Z�$|����\$����7/	RF�/ �H�/_	.�`"3�XF�<��
�]��-����<�Á?�����Ub2�]P���QG���F��w����PݣX	j�����-W�B��l��߯�������C�|4�?�t�"/b�������hA�����n�E���<�/��.�|)�/��H���A��y1P"�giV��@�9%B�䋁С�0(�f�@�߫�ba������8Rk�lo�g�ҧ)c<ٍ�~{����~�Ŷ`Ev:��'�wW~�V�~'�|M+���U����<�?L�"�����q4��8 �_P��__���_��&�;����#�`������b�"�߹�{��p�?$�?F��P��	���O�?���	���7��J��@��4}����� �?���#����x�����0�`��N�)�|i �������0��z�]���� ��/������L ������!&���������y�����"�p���;�T�p���r��ߚʲWʖu�
���5�U2g��m7ͩ�cX�4�z�;=����f7\�������d�3��>fŎ��սe�O�h ��Й�gclk��7Om���k�+�Q��yQ��*��=F�5�{3��ɁQ/��<��y5ʁ����7= _􊤌�C���_5���+�Z�,#�4]^,Ғun�O�j��N��rj��,�mGI�`Ι3�<=Y��0S���;��J����U��e��!4;�xy�0ENdW�\��_�k�KS��,se��Cī~�>�:2)�z�D}������A�YMCe�a�nl�l��R#�����[�]Q㺐O7�xp������4��S�z��#;�WN�yy��3m���Ψ�"/�si���])N�J:	�ѹ����.O�a����j�e���b�u�����=�r#[���g��������?, @���x; ����D���{�g���X@��l| H��ҿ��a�[�߼�����g�Z���iR���f(�6�b����?]�e���s��a*����F�>Kk���c�֙R���'�i�ؽ w�k�,�ճ������c��c�`��׽���ʠ��2^leD�F?nS���b�34��;ژ���{��T��ˍ��2������M� 9�٨1���O�A�W�j��bЗ�/��ڨ�Iw6li,��\���d����Ǽq2�1������&�P��8��zok���/{��sU���.ϳrwaW���vc��4KS�]����m�ꆁ�Z�]�����5���n�����2:VmëXn�O�HU�x��F!/��"��t=.I�%������ʡ2)�V��f��O�Muc$Ȱr[��]jطkmD�N^��먟���W@��c����/����@1 �����/������X@�?��� | �������o���~=�/}?�7��Q���gL/;������-�����>ڃk��7 �Lm�� ��@�_� ��Ǟ6��6��P�A��4:�����R}�5�Y3�ͤ�����P�6ʠ�.&��MY{XWg[��,��z�w��Diw�I��W|;@=ޓ��5*UT���x�s8[l��k-���9HK̹����>�=�Tk^i1�ި*bȬx!�V�yz^]��2;	\V�aQ��aSR�ҩ-��0[��L��^k��	�(ZDQeu�ŕ�Y6�����]�����������_�� �	��������?�����_�����2��p� ��Oi�م�� �����H���{���, ���"}:�D?�I�h9��0
x_��B�Dy���� 1����R�L�{?H��{��������F�V�lj�ͬ���H�[j��2��1��aY����i�kv�4���;TR�s:��-�UT�J�>��,7%?�)���NnG8	�e(x�k���t��6�}�ņ,
Բ��OM�֣�U��Ӎ]��o�
���Y
^��%�
��Ł����� ����.6���A���+��������˫�u#��R3
+�y{r�2�cvRc���_/\d�}w��|��cw��5�-���4��d��9V�m��5�1��Qr4�m{k���&�0����׷�y{j��_�?�����?@߂�g��H�A�Wq��/����/���������,D��?�������_����]�i�M��*;q���� k�{������i������N����dq_R���K��n��rI?,���wk�ď��S��fV-��n����x ҝ�4�Nܘ�s�|Δmĥ�s�5c1��|��CNj�����v���J_{�?ܺ�5��zU-���{a��FU��u�\��7�Z,Rk�8n��y�k�/3�lW��*�d�r�-��J�k����jnŪIG��*�==��?��L�X*����<���~����b�Pg��N8f�4��b&�b��&��n�6J�~�-��:�����V����w����3|��#^I�����}'��A�����������J*�������� �]��?4w%�����_9���0����W��Z��o�p��	x��x!�����#��Y���A���0�(�����9��c��!��������q�F��
��_[�������v��/D��o��� ������W[���ߩ��A���ǯ��O.p���������c 	���w��A�/`�8�'�������������!������������	X�� _���4/��M6�)!Q�P�eQ9����+�NI���S�j���m��z�JB���yt$B $��{k>�dJ`��ˮj�)E�v�T*��eD�2��4��Mk�,d9H�i���0:�����O��������z_�wS��xء���н/.s����z�}�Ve�f
����n唛�.5V��=;��V�0$��bfq�k���1��:IK�f}�_��$�eMa(��-�X�v�l��Yv��8u�����?��Na�����d<��>������!��g������S������x�� t(�����&
����I���x�_��/��w��?�������С�?�ee�� �!G\F�v��)#&�BMV�\�Ra:CfF�ʤ8F��TH"�@V�%���S�����������������6�I�xG��:��d�:������Lc��Ʋ��6�n�|���K�Z��θ�T,RV��t�3�D��j����1�#�Ey�|?X�S�촯Gﵜ�Y{���ٰ��<i����[���8�<�x��Y�m��J������T�?�����?��!�P��������pl��?�������_���ё�?�8�)������Ԟ��8�s:���qD��?�����Y�'���	��~��P����?�L����������8�����������\C��q,���_��;	��dc���B'���3�A��S���}�%������?t���<���,��"x�(M��M�h��v����ϻ���G�:��:�a����/���k�}�Q�ιsi��˒b���%�U�N�w�Y�M�r*���:]γ��+�l�$��ﳹ�uW�Gl} 8ʜT����ժ���Į�*���}B��|P�\�� 6������Ə��F[�Ҙ/�]���2��t��i��`Ά�`<�8G�1B-Y(���|��dҁ��&YA�eЈ��l�3W+e��0��{�ެ6h^���t��=����B'`�m}�ؽ��Q������I�jO�7���A��?>%��t
����h6��A��O��O��O��O���G���>~����(��m��$�?���F���<��?��8:�?^�?������Wō���k~����WZR(��ΰ���|��T!��4���U�׫.�{�9�zG���J��!�ܗ��2?��=���{�P �Y������,�&�`w�Bv5�����x���(4�,�x9�S�HtmLTf{3űZ�vԠ6)��N��wJt�M�4r�F�'��c?� 6���P�c�"��~˓�)~�B�;}�'K�P�3�Ф
�e�S�ٕW�1��$�sc���\E�2��8���2_��Z�0RUn��A.Sks%��5Z�!+�
zP�t:B�ʳ��h��mQ����UoU~���	�WE7��KAsZ�|I�9C�焒�%�Ve�gw�Y�%�^wH1���u��ʲ_��f��yR�RW,5E�-7ӄ(�wJg ٌ|�M��ɱ5<�r�l[�n��.D-���v���g��f�mi.K�����6qӫ2i�D6�-�Z������N�������� t���\�v`���b��׶�N��'������S�m�P�:JQ�J�)-�I)l&E��Y��U2
��UeҌ��T�QT�Q�j��2
	��?N�����������{����W�����F2���	�v3�>�����9���|��NW
����f&����/i��RìT�ĹO��1W���f�h.T��,FT\���.�\�� +hk�<����[�eI֊���o�S����?�GG��=3^�=*����ǣ��������	�Tn����_�N�c��x����_kJ�,�/����m��Fi~�Mw�GR��p8QSm������*L�.�D��48��r���y�� 3��11
چ*��!KNu���Lma纽������?��� �j�ߔx��&;�0�o�Ә��8�{$:��_����ط�
t
�����G���x�W��+���b����<����q��?&������=���������
"/Cv�U�9J2��������(����������r	dm��� "L�{ �m{v� d�����N���*�7���o.F6����yų��m�Sr:tFD�<���A���&�v�U�U�\��z�|�K�9��]�J��Av����3��<k6чj@������������+�= �n^��A��2>	~�uZ�I]o�Za�rJ����k(������n�L����n٭�zta�9�
�b���M)�?ԴH7Q��;T�*5Œ�+�eǟ�Ϳ�W����\c0ʕ*a�Gww=v�N��&0��m��Y�L�7��]-�}����R�Q��jڹ.ߍ��>h���b%��W�x��K��?�bI.��C�' ��c�c��*�r�	��&h�4�`(Z��D|�F��b��r�EI��g��\~.�cxA'H�e�x?B������p�����a�� ����ɖ�����g�ek�}�*m�� �}�c~�>����3x�U 9{&�%ز����.s<kϡ�bBЈH(д0���Ƅh�BB��A�	�r��S�]�
;g-;�/ț��Y����!"���GɯN}����%�������a����+�Ɔ\���� Z�bB����MC5<�"�"4F���+�w�����wB�J PEy��0���`>�qQ6N��O���6F�|�fT#����+\ ND�������Ǵ.�5p�PV/��*Lm�o��h _Z��7�}�q���"l��;pe���Z8�->"�3ۊd�K=����OP�c޺yHX{�F6�chC��]�ϊ5�>a�;\�M��ht�]Ɨ;=�]:��Ħ�߾%�U$�߾�}�I06Pۊ���Q�.d�G9�,�n�k4Z���
���8НcA[@s��0��Bۧ�?�m�f̢A1W��<�m5e{�Q^�ùS۹Q���E](���*��Րny@VP��URd������~� ���p�Ui@(�3ہk(��2�"t�:�JC]v�c�O6�՚a(x�$�k�i�S�טBp�����΢�H<��[�������o������?S�4�j΄�K����Û؀��TiX\�/m|�u�n������R14y��z�*_6c�5���5i�6b�Z�!������|�!TT�w�!�ش#�`����!�9��e�+C�Z����x��#������~a�U�4�� ���`���P�K�ݸ�/A�!�Qe�5��o����o�P���|�:u�<�q���Ύ��Ȫ����Ʋ��v�/<��j6�� ��D���?��V|����m�W����'�?�fc�� �sth�?t0]��;W�=�N��</�J⭘/�6�N��s��#�|����;��@�������Y@� �\ؾ7�=���)H<�ׅ�O(���9�cٲ��a%�p�N�,���Q"�X��]ʁ��u��qG�����:������C㷄I��)��b�?�GS�%���� �*�=�GS�1�u4��Ws�PӑP�EF�/?�-���92�����0���c�e�m�^����S�{٭erσm�ՓZ�W�G,�T�����p$>_�����R狧�}���4��rd����J+�,+).KC9�@&5J�G�
G�ƍ(Y����5e���i�e3P���;%��8��:��{��D3 ��c�෧���j<�	��z�܊����Տ�����NɊ��l��4Y�hȪ���e9�f��#3�ddE�g
���L���Qǀ��^����~{ca��nuW��W�U9y��֬���~<tn#;y����`�sM|�����h�����m���ZH�RMj��J�P�zR�J��������H5>�kI����{17��]jW�N�����Z��굱^�,^n��W��F)w��X�ū�s���*��-���Lۙ"_�V3�K���^R��7N���ԑS�+�,=�]�����O�8����'ؑh?�Mw�d�� �a�cK	����M�C��K}�C���/
���y_y����]��$,�RY���z"��}�ȗjb=��3҉�$t�Y{�[��k�K�Εo��d2��,Ʌ�$�Z�V	w[>�'q�H"���ݼm{�7�tP�ꖫ�e�h����Z�T��I�~�U���]m��v�i�-tGutj[o3�Ԉ{�6<�\�ey)W@϶;|G����/�m�
���8'|'�X�Ŝ�n��j�A*~\S.S���
��n�0�┋u�!�ð�F���T��$t���%�~��]���z�g�</��8�d��:�~X	o��58����"+��;_�)�H`0�H���z���p�a�q��8��G!�G9�۪�"<ug�a��:|(9�8�t�k�cn�[�?ʎfV>��p�?P�+�?)�����M2,E�������;}���bXIEv���i���,02��ql�w0w��in��Mx��.�39�A��c��H`Y���F�/fǜ����n�w��� 嶝U������/@� ��	�<�����m��m�������|=����ٶ�>b�3�'�GM}\�pW��<��}X���og�aT�PM�n�\�����0=�̛2�*��:pf/�E�P����AⓃ�����L<�'LsF�i�h�`[+��nfj�b����V����)�h�^�����33��/;7F�����������M�.����P�~�ڿ4��]Ϟ��czm���Os��F�O�X&��C�	��a&�p){��<T�\d#[����9�Y�=�q��a����pq�3.`��|3������?�C@�Y��Gs��߃����V����+.T�6b���:�t4,`�P�p�G��F�%���X��1���3�ߒH���o����Y�<�}q�a��@��"� ����|�L�7����� ���]Yo�@~�_1�"���رS���C�K[)j_�<c��@���;����&�#��{!ػ���w����Kh<C|�
U������<In�T}7-/2/�)Y�j��V������u99��� ��@��������$"q4�nL���"��|�u��g�&,�fx
&�I�5Ό�f-�R} 3Ch��+L�<��������kx
��iL.i*����|&֊��gD>�T�l�K��w.��E�q��er�L$��q���ҟ6j蕡�8�L"�ہ�*�4s�*��rch��G�Xg�	5J-����ҽeS�<S{&82��1]�V<�Kک�����K�o�r���i8_-�cYb#�3�|eU��울������S���m���������<��F^?����:v��}+p\+�m���v�����vzT���޽p��Ƈ�h� �+44�0Ae�d���z����\j�0T���h��je���Bk�Ӡ ��ć:�uMo
]K��0��}K��h�-����g�T5��5�����Ո� ��Y��7�����&�n83K�C)v?�#sg����R��v�x��wfuU����j9���� �����~�WxL���Q����W0�o�Dt�
���A_�v���?� c$���.���"�+@��N"F�V��Nn�50[�Y�6�Wr��Z�K�����K��S#�H����ƚ��6�O���>�D'N/n�eL�(3�X�3�cP��s~���Q:=��3���`0��`0��`0��'� 0 