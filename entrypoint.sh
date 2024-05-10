#!/usr/bin/env bash


#
#
#


WORK_DIR="/workdir"
EXTRACTED_ISO_ROOT_PATH="${WORK_DIR}/extracted_iso"

function _help_and_exit {
  echo 'Usage:'
  echo 'isolinux.cfg grub.cfg ks.cfg and input iso file must exist in current directory'
  echo '${1} - ISO Label'
  echo '${2} - input ISO basename in "workdir" directory'
  echo '${3} - output ISO basename in "workdir" directory'
  exit 1
}

function _extract_iso {
  local iso_path
  local extract_dir_path
  iso_path="${1}"
  extract_dir_path="${2}"

  mkdir --parents "${extract_dir_path}"
  osirrox -indev "${iso_path}" -extract / "${extract_dir_path}"
}

function _copy_modified_file_in_iso_directory {
  local extracted_iso_root_path
  local modified_files_root_path
  modified_files_root_path="${1}"
  extracted_iso_root_path="${2}"

  cp --verbose "${modified_files_root_path}/isolinux.cfg" "${extracted_iso_root_path}/isolinux/isolinux.cfg"
  cp --verbose "${modified_files_root_path}/grub.cfg" "${extracted_iso_root_path}/EFI/BOOT/grub.cfg"
  cp --verbose "${modified_files_root_path}/ks.cfg" "${extracted_iso_root_path}/ks.cfg"
}

function _generate_iso {
  local iso_label
  local modified_iso_path
  local extracted_iso_root_path
  iso_label="${1}"
  modified_iso_path="${2}"
  extracted_iso_root_path="${3}"

  genisoimage \
  -U \
  -r \
  -v \
  -T \
  -J \
  -joliet-long \
  -V "${iso_label}" \
  -volset "${iso_label}" \
  -A "${iso_label}" \
  -b isolinux/isolinux.bin \
  -c isolinux/boot.cat \
  -no-emul-boot \
  -boot-load-size 4 \
  -boot-info-table \
  -eltorito-alt-boot \
  -eltorito-boot images/efiboot.img \
  -no-emul-boot \
  -o "${modified_iso_path}" "${extracted_iso_root_path}"

  implantisomd5 "${modified_iso_path}"
}

function _clean {
  local extracted_iso_root_path
  extracted_iso_root_path="${1}"

  rm --force --recursive "${extracted_iso_root_path}"
}

function _main {
  local iso_label
  local input_iso_filename
  local output_iso_filename
  iso_label="${1}"
  input_iso_filename="${2}"
  output_iso_filename="${3}"

  [[ -n "${iso_label}" ]] || _help_and_exit
  [[ -n "${input_iso_filename}" ]] || _help_and_exit
  [[ -n "${output_iso_filename}" ]] || _help_and_exit
  [[ -f "${WORK_DIR}/isolinux.cfg" ]] || _help_and_exit
  [[ -f "${WORK_DIR}/grub.cfg" ]] || _help_and_exit
  [[ -f "${WORK_DIR}/ks.cfg" ]] || _help_and_exit
  [[ -f "${WORK_DIR}/${input_iso_filename}" ]] || _help_and_exit

  _extract_iso "${WORK_DIR}/${input_iso_filename}" "${EXTRACTED_ISO_ROOT_PATH}"
  _copy_modified_file_in_iso_directory "${WORK_DIR}" "${EXTRACTED_ISO_ROOT_PATH}" 
  _generate_iso "${iso_label}" "${WORK_DIR}/${output_iso_filename}" "${EXTRACTED_ISO_ROOT_PATH}"
  _clean "${EXTRACTED_ISO_ROOT_PATH}"

}


_main "${@}"
