pkgname=clash-utils
pkgver=r1
pkgrel=1
license=('MIT')
pkgdesc='A faster way to switch from clash configs'
url='https://github.com/moecater/PKGBUILD/tree/main/clash-tuner'
arch=('any')
depends=('wget')
source=(
	'file://clash-meta-daemon-perm@.service'
	'file://clash-meta-daemon@.service'
	'file://clash-daemon-perm@.service'
	'file://clash-daemon@.service'
	'file://clash-tuner.service'
	'file://clash-tuner.sh'
	'file://clash-tuner.xml'
	'file://clash-updater.sh'
	'file://clash-updater.service'
	'file://clash-updater.timer'
	'file://env'
	'file://systemd-resolved_china-dns.conf'
	'file://systemd-resolved_world-dns.conf'
	'file://systemd-resolved_clash-dns.conf'
	'file://networkd-dispatcher_restart-on-nif-changes'
	'file://on-start-script'
	'file://on-stop-script'
)
sha256sums=('b2a89d2a7f54d65c8610d9090152274657592d65afc9cd7c4add9bcf2f5a3942'
	'adb0188271402abe46dcb76f0ef4087627d75c45f96d30f9664a9206080ef084'
	'c72e99a1999c9b77b24f5bf25ecf648c947592242588c9e706d0a9e8e4de32f1'
	'85104acab2dbdf1f3c7b8bbe082af2d0c098515478094824e087e9afb9c59f9f'
	'a84323f44179641d48c060f54c5345133389be017b19dd3d9eb393b7fba7dc9b'
	'0512f4c4cb6ff7f3f7811182fdf774e173866cde1944507410733a8536323e63'
	'4e78654f43954c0780766a1731f25b8bc5e354cdf056bcad09bdb4cc99f0b326'
	'c137a799bb3e511aff0e30197bd19db13e26e2d12fe7af05eff9ed01941a7cf7'
	'eda950a7ad592604d2d0178cdc00cec50db9777798d628ed7c5d2b68a64a9642'
	'445461fe186052fa85daf146eb654fd007310fa022545e1273986b53b49e7eae'
	'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855'
	'fa32fd50587f987a5bb1b361fe53e0a3d2678563695dd6f60fc2669ffc997da6'
	'e5821af12e04a958ee86317366e057178dfc79f9d1c340acab91d6448c00ddeb'
	'ec907b5c269b8354abab976df63714c57a10347e353781839dae5c5c0cb5fd60'
	'bd14640554989db2f4b991ada6b8ecc98dc02c8e44d8d4482a84bd26ec8006be'
	'349b7fc427a3a25cc85184c675d51abedfaec60808a9abc75a5efdb3d3c888d5'
	'637977946bbeb8cce785892c83c312df089c13ec14c40399cc09976a30a49c56')

pkgver() {
	printf "r%s" "$(git rev-list --count HEAD)"
}

package() {
	install -Dm644 clash-tuner.service -t "${pkgdir}/usr/lib/systemd/system/"
	install -Dm644 clash*daemon*.service -t "${pkgdir}/usr/lib/systemd/system/"
	install -Dm644 clash-updater.service -t "${pkgdir}/usr/lib/systemd/user/"
	install -Dm644 clash-updater.timer -t "${pkgdir}/usr/lib/systemd/user/"
	install -Dm755 "clash-updater.sh" -T "${pkgdir}/usr/bin/clash-updater"
	install -Dm755 "clash-tuner.sh" -T "${pkgdir}/usr/bin/clash-tuner"
	install -Dm644 "clash-tuner.xml" -t "${pkgdir}/usr/lib/firewalld/services/"
	install -Dm644 "env" -t "${pkgdir}/etc/clash-tuner/"
	install -Dm755 on-*-script -t "${pkgdir}/usr/share/doc/clash-tuner/"
	install -Dm755 "networkd-dispatcher_restart-on-nif-changes" -t "${pkgdir}/usr/share/doc/clash-tuner/"
	install -Dm644 systemd*dns.conf -t "${pkgdir}/usr/share/doc/clash-tuner/"
}
