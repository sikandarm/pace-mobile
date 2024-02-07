class AddCARObj {
  String? originatorName;
  String? contractorSupplier;
  String? caReportDate;
  String? ncNo;
  String? purchaseOrderNo;
  String? partDescription;
  String? partId;
  String? quantity;
  String? dwgNo;
  List<String>? activityFound;
  String? description;
  String? actionToPrevent;
  String? disposition;
  String? responsiblePartyName;
  String? responsiblePartyDate;
  String? correctiveActionDesc;
  String? approvalName;
  String? approvalDate;
  String? userId;

  AddCARObj({
    this.originatorName,
    this.contractorSupplier,
    this.caReportDate,
    this.ncNo,
    this.purchaseOrderNo,
    this.partDescription,
    this.partId,
    this.quantity,
    this.dwgNo,
    this.activityFound,
    this.description,
    this.actionToPrevent,
    this.disposition,
    this.responsiblePartyName,
    this.responsiblePartyDate,
    this.correctiveActionDesc,
    this.approvalName,
    this.approvalDate,
    this.userId,
  });

  AddCARObj.fromJson(Map<String, dynamic> json) {
    originatorName = json['originatorName'];
    contractorSupplier = json['contractorSupplier'];
    caReportDate = json['caReportDate'];
    ncNo = json['ncNo'];
    purchaseOrderNo = json['purchaseOrderNo'];
    partDescription = json['partDescription'];
    partId = json['partId'];
    quantity = json['quantity'];
    dwgNo = json['dwgNo'];
    activityFound = json['activityFound'].cast<String>();
    description = json['description'];
    actionToPrevent = json['actionToPrevent'];
    disposition = json['disposition'];
    responsiblePartyName = json['responsiblePartyName'];
    responsiblePartyDate = json['responsiblePartyDate'];
    correctiveActionDesc = json['correctiveActionDesc'];
    approvalName = json['approvalName'];
    approvalDate = json['approvalDate'];
    userId = json['userId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['originatorName'] = originatorName;
    data['contractorSupplier'] = contractorSupplier;
    data['caReportDate'] = caReportDate;
    data['ncNo'] = ncNo;
    data['purchaseOrderNo'] = purchaseOrderNo;
    data['partDescription'] = partDescription;
    data['partId'] = partId;
    data['quantity'] = quantity;
    data['dwgNo'] = dwgNo;
    data['activityFound'] = activityFound;
    data['description'] = description;
    data['actionToPrevent'] = actionToPrevent;
    data['disposition'] = disposition;
    data['responsiblePartyName'] = responsiblePartyName;
    data['responsiblePartyDate'] = responsiblePartyDate;
    data['correctiveActionDesc'] = correctiveActionDesc;
    data['approvalName'] = approvalName;
    data['approvalDate'] = approvalDate;
    data['userId'] = userId.toString();
    return data;
  }
}
