work_dir=~/ait
superuser_file='latestmagisk'
install_script='flash-all.sh'
install_script_reduced='flash-all-reduced.sh'
install_script_expected='flash-all-expected.sh'
unpack_dir="${work_dir}/unpack"
# Set later; declared here for global scope:
image_dir=

# supersu, vanilla:     http://forum.xda-developers.com/apps/supersu/stable-2016-09-01supersu-v2-78-release-t3452703
#vanilla_supersu_link='https://redirect.viglink.com/?format=go&jsonp=vglnk_149107958792013&key=f0a7f91912ae2b52e0700f73990eb321&libId=j0zq5ls401000n4o000DA1wr7s3hi5m2ic&loc=https%3A%2F%2Fforum.xda-developers.com%2Fapps%2Fsupersu%2Fstable-2016-09-01supersu-v2-78-release-t3452703&v=1&out=https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsupersu%2Fdownload%2Fzip%2FSuperSU-v2.79-201612051815.zip&title=%5BSTABLE%5D%5B2016.12.15%5D%20SuperSU%20v2.79&txt=https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fs...1612051815.zip'
vanilla_supersu_link='https://redirect.viglink.com/?format=go&jsonp=vglnk_150663378140511&key=f0a7f91912ae2b52e0700f73990eb321&libId=j84y56to01000n4o000DA8n4kpnzc90wi&loc=https%3A%2F%2Fforum.xda-developers.com%2Fapps%2Fsupersu%2Fstable-2016-09-01supersu-v2-78-release-t3452703&v=1&out=https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsupersu%2Fdownload%2Fzip%2FSuperSU-v2.82-201705271822.zip&title=%5BSTABLE%5D%5B2017.05.27%5D%20SuperSU%20v2.82&txt=https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fs...1705271822.zip'
# supersu for oreo:     https://forum.xda-developers.com/showpost.php?p=71561057&postcount=9345
supersu_oreo_link='https://download.chainfire.eu/1023/SuperSU/SuperSU-v2.79-SR4-20170323220017-ODP1-5X-6P.zip?retrieve_file=1'
# supersu, systemless:  http://forum.xda-developers.com/showpost.php?p=64161125&postcount=3
systemless_supersu_link='https://redirect.viglink.com/?format=go&jsonp=vglnk_149108038109010&key=f0a7f91912ae2b52e0700f73990eb321&libId=j0zqr2t401000n4o000DArp42e9tu4z8e&loc=https%3A%2F%2Fforum.xda-developers.com%2Fshowpost.php%3Fp%3D64161125%26postcount%3D3&v=1&out=http%3A%2F%2Fdownload.chainfire.eu%2F897%2FSuperSU%2FBETA-SuperSU-v2.67-20160121175247.zip&title=EXPERIMENT%3A%20Root%20without%20modifying%20%2Fsystem%20%232%3A%20Automation%20-%20Post%20%233&txt=BETA-SuperSU-v2.67-20160121175247.zip'
phh_superuser_link='https://superuser.phh.me/superuser.zip'
# Observed to work for v14.0.  Monitor for updates or lack thereof.
magisksu_link='http://tiny.cc/latestmagisk'
superuser_link="${magisksu_link}"
