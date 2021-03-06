#!/bin/ksh -p
#
# CDDL HEADER START
#
# The contents of this file are subject to the terms of the
# Common Development and Distribution License (the "License").
# You may not use this file except in compliance with the License.
#
# You can obtain a copy of the license at usr/src/OPENSOLARIS.LICENSE
# or http://www.opensolaris.org/os/licensing.
# See the License for the specific language governing permissions
# and limitations under the License.
#
# When distributing Covered Code, include this CDDL HEADER in each
# file and include the License file at usr/src/OPENSOLARIS.LICENSE.
# If applicable, add the following below this CDDL HEADER, with the
# fields enclosed by brackets "[]" replaced with your own identifying
# information: Portions Copyright [yyyy] [name of copyright owner]
#
# CDDL HEADER END
#

#
# Copyright 2007 Sun Microsystems, Inc.  All rights reserved.
# Use is subject to license terms.
#

#
# Copyright (c) 2017, Datto, Inc. All rights reserved.
#

. $STF_SUITE/include/libtest.shlib

#
# DESCRIPTION:
# 'zfs mount -l' should accept a valid key as it mounts the filesystem.
#
# STRATEGY:
# 1. Create an encrypted dataset
# 2. Unmount and unload the dataset's key
# 3. Attempt to mount the dataset
# 4. Verify the key is loaded correctly
#

verify_runnable "both"

typeset CRYPTDS="cryptds"
typeset PASSKEY="abcdefgh"

function cleanup
{
	datasetexists $TESTPOOL/$CRYPTDS && \
		log_must $ZFS destroy -f $TESTPOOL/$CRYPTDS
}

log_onexit cleanup

log_assert "'zfs mount -l' should properly load a valid wrapping key"

log_must eval 'echo $PASSKEY | $ZFS create -o encryption=on \
	-o keyformat=passphrase $TESTPOOL/$CRYPTDS'

log_must $ZFS unmount $TESTPOOL/$CRYPTDS
log_must $ZFS unload-key $TESTPOOL/$CRYPTDS

log_must eval '$ECHO $PASSKEY | $ZFS mount -l $TESTPOOL/$CRYPTDS'
mounted $TESTPOOL/$CRYPTDS || \
	log_fail "Filesystem $TESTPOOL/$TESTFS is unmounted"

log_pass "'zfs mount -l' properly loads a valid wrapping key"
