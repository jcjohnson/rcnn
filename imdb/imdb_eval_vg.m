function res = imdb_eval_vg(cls, boxes, imdb, suffix, nms_thresh)

    if ~exist('suffix', 'var') || isempty(suffix) || strcmp(suffix, '')
      suffix = '';
    else
      if suffix(1) ~= '_'
        suffix = ['_' suffix];
      end
    end

    if ~exist('nms_thresh', 'var') || isempty(nms_thresh)
      nms_thresh = 0.3;
    end

    roidb = imdb.roidb_func(imdb);
    class_id = imdb.class_to_id(cls);
    num_images = length(imdb.image_ids);
    dets = cell(num_images, 1);
    gt = cell(num_images, 1);
    for i = 1:num_images
        rois = roidb.rois(i);
%         I = find(rois.gt && rois.class == class_id);
        gt{i} = rois.boxes(rois.gt & rois.class == class_id, :);
        keep = nms(boxes{i}, nms_thresh);
        dets{i} = boxes{i}(keep, :);
    end
    
    [precision, recall, ap, true_positives] = evaluate_detections(dets, gt, 0.5);
    ap_auc = xVOCap(recall, precision);
    
%     disp(cls);
%     disp(ap_auc);
%     for i = 1:num_images
%         tp = true_positives{i};
%         disp([tp dets{i}(:, 5)]);
%         if ~any(tp), continue, end;
%         img = imread(imdb.image_at(i));
%         subplot(1, 2, 1);
%         showboxesc(img, dets{i}(~tp, :), 'r', '-');
%         subplot(1, 2, 2);
%         showboxesc(img, dets{i}(tp, :), 'g', '-');
%         pause;
%     end
    
    res.recall = recall;
    res.precision = precision;
    res.ap = ap;
    res.ap_auc = ap_auc;
end